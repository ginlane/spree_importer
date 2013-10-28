class Spree::ImportSourceFile < ActiveRecord::Base
  has_many :imports
  validates_uniqueness_of :data

  attr_accessor :import_warnings, :import_errors, :imported_records

  def csv?
    mime =~ /csv/
  end

  def import!
    importer     = SpreeImporter::Base.new
    importer.csv = data
    importer.parse

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
    end
  end
end
