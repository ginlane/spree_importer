class Spree::ImportSourceFile < ActiveRecord::Base
  include Enumerable
  validates_uniqueness_of :data, allow_nil: true

  serialize :import_warnings
  serialize :import_errors
  serialize :imported_records

  has_many :products, foreign_key: :batch_id
  has_many :variants, foreign_key: :batch_id

  default_scope -> {
    order "created_at desc"
  }

  def csv?
    mime =~ /csv/
  end

  def each
    importer.csv.each { |*args| yield *args }
  end

  def import_from_google!(token, worksheet_title=nil)
    session   = GoogleDrive.login_with_oauth token
    ss        = session.spreadsheet_by_key spreadsheet_key
    ws        = ss.worksheet_by_title(worksheet_title) || ss.worksheets.first
    wid       = File.basename(ws.worksheet_feed_url)
    gid       = wid
    csv       = ss.export_as_string :csv, ss.worksheets.find_index {|w|w.title == ws.title}

    self.data = csv.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?").encode("UTF-8")
    self.file_name = "#{ss.title} - #{ws.title}"
    self.spreadsheet_url = ss.human_url
    save

    # importer.import :variant, batch_id: id

    import!
  end

  def google_spreadsheet(token)
    session   = GoogleDrive.login_with_oauth token
    session.spreadsheet_by_key spreadsheet_key
  end

  def flat_worksheet(token)
    ss = google_spreadsheet(token)
    ss.worksheet_by_title('Flat') || ss.add_worksheet('Flat')
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

      importer.import :taxonomy

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
    save!
  end

  def importer(force = false)
    if @importer.nil? || force
      @importer     = SpreeImporter::Importer.new
      @importer.csv = data
      @importer.parse
    end
    @importer
  end

  protected
  # def set_feed_url_from_human_url
  #   return if spreadsheet_url.nil?
  #   parsed                    = Rack::Utils.parse_query spreadsheet_url.split("?").last

  #   ap parsed
  #   self.spreadsheet_key =  parsed["key"]
  # end
end
