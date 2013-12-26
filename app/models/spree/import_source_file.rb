class Spree::ImportSourceFile < ActiveRecord::Base
  include Enumerable
  validates_uniqueness_of :data, allow_nil: true

  serialize :import_warnings
  serialize :import_errors
  serialize :imported_records

  default_scope -> {
    order "created_at desc"
  }

  def csv?
    mime =~ /csv/
  end

  def each
    importer.csv.each { |*args| yield *args }
  end

  def import_from_google!(token)
    set_feed_url_from_human_url if spreadsheet_feed_url.nil?

    session   = GoogleDrive.login_with_oauth token
    ss        = GoogleDrive::Spreadsheet.new session, spreadsheet_feed_url
    self.data = ss.export_as_string "csv"
    import!
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
    update_attribute :spreadsheet_feed_url, ss.worksheets_feed_url
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
      importer.import :variant
    end

    self.import_warnings  = importer.warnings
    self.imported_records = importer.records
    self.rows             = rows

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
  def set_feed_url_from_human_url
    return if spreadsheet_url.nil?

    parsed                    = Rack::Utils.parse_query spreadsheet_url.split("?").last
    key                       = parsed["key"]
    self.spreadsheet_feed_url = "https://spreadsheets.google.com/feeds/worksheets/#{key}/private/"
  end
end
