class Spree::ImportSourceFile < ActiveRecord::Base
  include Enumerable


  serialize :import_warnings
  serialize :import_errors
  serialize :imported_records

  has_many :products, foreign_key: :batch_id, dependent: :destroy
  has_many :variants, foreign_key: :batch_id

  has_many :stock_transfers, foreign_key: :batch_id#, dependent: :destroy
  has_many :stock_movements, through: :stock_transfers#, dependent: :destroy

  has_many :taxons, -> { group(:taxon_id) }, through: :products

  default_scope -> {
    order "created_at desc"
  }

  def csv?
    mime =~ /csv/
  end

  def each
    importer.csv.each { |*args| yield *args }
  end

  def meta_from_google(token, worksheet_title='Initial')
    session   = GoogleDrive.login_with_oauth token
    ss        = session.spreadsheet_by_key spreadsheet_key
    ws        = ss.worksheet_by_title(worksheet_title)
    ws ||= ss.worksheets.first
    wid       = File.basename(ws.worksheet_feed_url)
    gid       = GID_TABLE[wid.to_sym]
    self.file_name = "#{ss.title} - #{ws.title}"
    self.spreadsheet_url = ss.human_url
    save
  end

  def import_from_google!(token, worksheet_title='Initial')
    session   = GoogleDrive.login_with_oauth token
    ss        = session.spreadsheet_by_key spreadsheet_key
    ws        = ss.worksheet_by_title(worksheet_title)
    wid       = File.basename(ws.worksheet_feed_url)
    gid       = GID_TABLE[wid.to_sym]
    csv       = ss.export_as_string :csv, gid #ss.worksheets.find_index {|w|w.title == ws.title}

    self.data = csv.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?").gsub(/[\u201c\u201d]/, '"')
    self.file_name = "#{ss.title} - #{ws.title}"
    self.spreadsheet_url = ss.human_url
    save

    if worksheet_title == 'Flat'
      self.class.transaction do
        importer.import :variant, batch_id: id
      end

      self.import_warnings  = importer.warnings
      self.imported_records = importer.records
      save
    else
      import!
    end
  end

  def google_spreadsheet(token)
    session   = GoogleDrive.login_with_oauth token
    session.spreadsheet_by_key spreadsheet_key
  end

  def flat_worksheet(token)
    ss = google_spreadsheet(token)
    ss.worksheet_by_title('Flat') || ss.add_worksheet('Flat')
  end

  def worksheet_with_title(token,title)
    raise 'no title' unless title
    ss = google_spreadsheet(token)
    ss.worksheet_by_title(title) || ss.add_worksheet(title)
  end

  def create_in_google!(token)
    session   = GoogleDrive.login_with_oauth token
    ss        = session.create_spreadsheet "#{file_name}-#{id}"
    csv       = CSV data
    rows      = csv.read
    worksheet = ss.worksheets.first
    rows.each_with_index do |row, i|
      row.each_with_index do |cell, n|
        worksheet[i+1,n+1] = cell
      end
    end

    if import_errors
      import_errors.each do |error|
        worksheet[error.row+1,error.column_index+1] = "[[ERROR: #{error.message}]]\
#{worksheet[error.row+1,error.column_index+1]}"
      end
    end

    worksheet.save
    update_attribute :spreadsheet_url, ss.human_url
    update_attribute :spreadsheet_key, ss.key
  end

  def headers
    importer.headers
  end

  def import!
    import_errors.try :clear
    self.rows = importer.csv.inject(0) { |acc| acc + 1 }
    self.class.transaction do
      importer.option_headers.each do |header|
        importer.import :option, option_name: header.key, create_record: true
      end
      importer.property_headers.each do |header|
        importer.import :property, property_name: header.key, create_record: true
      end

      importer.prototype_headers.each do |header|
        importer.import :prototype, prototype_name: header.key, create_record: true
      end
    end
    # self.class.transaction do
      importer.import :taxonomy
    # end
    self.class.transaction do
      importer.import :product, batch_id: id
      importer.import :variant, batch_id: id
    end

    self.import_warnings  = importer.warnings
    self.imported_records = importer.records

  rescue SpreeImporter::ImportException => e
    self.import_errors    = importer.errors.values.flatten
    self.import_warnings  = { }
    self.imported_records = { }
    self.rows             = 0
  ensure
    save
  end

  def importer(force = false)
    if @importer.nil? || force
      @importer     = SpreeImporter::Importer.new
      @importer.csv = data
      @importer.parse
    end
    @importer
  end

  GID_TABLE = {
    od6: 0,
    od7: 1,
    od4: 2,
    od5: 3,
    oda: 4,
    odb: 5,
    od8: 6,
    od9: 7,
    ocy: 8,
    ocz: 9,
    ocw: 10,
    ocx: 11,
    od2: 12,
    od3: 13,
    od0: 14,
    od1: 15,
    ocq: 16,
    ocr: 17,
    oco: 18,
    ocp: 19,
    ocu: 20,
    ocv: 21,
    ocs: 22,
    oct: 23,
    oci: 24,
    ocj: 25,
    ocg: 26,
    och: 27,
    ocm: 28,
    ocn: 29,
    ock: 30,
    ocl: 31,
    oe2: 32,
    oe3: 33,
    oe0: 34,
    oe1: 35,
    oe6: 36,
    oe7: 37,
    oe4: 38,
    oe5: 39,
    odu: 40,
    odv: 41,
    ods: 42,
    odt: 43,
    ody: 44,
    odz: 45,
    odw: 46,
    odx: 47,
    odm: 48,
    odn: 49,
    odk: 50,
    odl: 51,
    odq: 52,
    odr: 53,
    odo: 54,
    odp: 55,
    ode: 56,
    odf: 57,
    odc: 58,
    odd: 59,
    odi: 60,
    odj: 61,
    odg: 62,
    odh: 63,
    obe: 64,
    obf: 65,
    obc: 66,
    obd: 67,
    obi: 68,
    obj: 69,
    obg: 70,
    obh: 71,
    ob6: 72,
    ob7: 73,
    ob4: 74,
    ob5: 75,
    oba: 76,
    obb: 77,
    ob8: 78,
    ob9: 79,
    oay: 80,
    oaz: 81,
    oaw: 82,
    oax: 83,
    ob2: 84,
    ob3: 85,
    ob0: 86,
    ob1: 87,
    oaq: 88,
    oar: 89,
    oao: 90,
    oap: 91,
    oau: 92,
    oav: 93,
    oas: 94,
    oat: 95,
    oca: 96,
    ocb: 97,
    oc8: 98,
    oc9: 99
  }
end
