class Spree::ImportSourceFile < ActiveRecord::Base
  has_many :imports
  validates_uniqueness_of :data

  attr_accessor :imported_records, :warnings

  def csv?
    mime =~ /csv/
  end

  def import!
    importer     = SpreeImporter::Base.new
    importer.csv = data
    importer.parse

    self.imported_records = { options: 0, properties: 0, prototypes: 0, products: 0 }.with_indifferent_access
    self.warnings         = imported_records.dup
    self.class.transaction do
      %w[ option property prototype ].each do |record_type|
        importer.send("#{record_type}_headers").each do |header|
          rec = importer.import record_type, "#{record_type}_name" => header.sanitized, create_record: true
          mark_warnings_and_totals record_type, rec
        end
      end

      importer.import :product

      self.warnings = importer.errors
    end
  end

  protected
  def mark_warnings_and_totals(record_type, record)
    [ record ].flatten.each do |rec|
      if rec.valid?
        imported_records[record_type.pluralize] += 1
      else
        warnings[record_type.pluralize]         += 1
      end
    end
  end
end
