class Spree::Import < ActiveRecord::Base
  serialize :arguments
  serialize :records_created
  validates_presence_of :target

  belongs_to :import_source_file, class_name: "Spree::ImportSourceFile"
  accepts_nested_attributes_for :import_source_file
  before_save :ensure_order_of_array_fields

  def run!
    importer     = SpreeImporter::Base.new
    importer.csv = import_source_file.data
    importer.parse

    # hate this but product acts different than the other import commands
    if target.to_s == "product"
      importer.import target
    else
      arguments.each do |name|
        importer.import target, "#{target}_name" => name, create_record: true
      end
    end
  end

  protected
  def ensure_order_of_array_fields
    arguments.sort! unless arguments.nil?
  end
end
