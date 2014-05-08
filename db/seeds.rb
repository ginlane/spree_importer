

Spree::StockLocation.where(name: "Default").first_or_create  unless Spree::StockLocation.count
Spree::ShippingCategory.where(name: "Default").first_or_create

import_path = "#{Rails.root}/db/import.csv"
if File.exist?(import_path)
  data     = File.read import_path
  SpreeImporter.config.progress_logging_enabled = true
  importer     = SpreeImporter::Importer.new
  importer.csv = data
  importer.parse

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

  importer.import :product
  importer.import :variant

end
