class Spree::ImportSourceFile < ActiveRecord::Base
  include Enumerable
  validates_uniqueness_of :data

  attr_accessor :import_warnings, :import_errors, :imported_records

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
        importer.import :option, option_name: header.sanitized, create_record: true
      end

      importer.property_headers.each do |header|
        importer.import :property, property_name: header.sanitized, create_record: true
      end

      importer.prototype_headers.each do |header|
        importer.import :prototype, prototype_name: header.sanitized, create_record: true
      end

      importer.import :product

      self.import_warnings  = importer.warnings
      self.import_errors    = importer.errors
      self.imported_records = importer.records

      update_column :rows, rows
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
