class Spree::ImportSourceFile < ActiveRecord::Base
  include Enumerable
  validates_uniqueness_of :data

  serialize :import_warnings
  serialize :import_errors
  serialize :imported_records

  def csv?
    mime =~ /csv/
  end

  def each
    importer.csv.each { |*args| yield *args }
  end

  def headers
    importer.headers
  end

  def import!
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

      importer.import :product
      # importer.import :stock_item

      self.import_warnings  = importer.warnings
      self.import_errors    = importer.errors
      self.imported_records = importer.records
      self.rows             = rows

      save!
    end
  end

  def importer(force = false)
    if @importer.nil? || force
      @importer     = SpreeImporter::Importer.new
      @importer.csv = data
      @importer.parse
    end
    @importer
  end
end
