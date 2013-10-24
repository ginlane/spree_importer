class Spree::ImportSourceFile < ActiveRecord::Base
  has_many :imports

  def csv?
    mime =~ /csv/
  end

  def import!
    importer     = SpreeImporter::Base.new
    importer.csv = data
    importer.parse

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
  end
end
