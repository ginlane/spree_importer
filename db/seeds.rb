
Spree::StockLocation.create(name: "Default")    unless Spree::StockLocation.any?
Spree::ShippingCategory.create(name: "Default") unless Spree::ShippingCategory.any?

import_path = "#{Rails.root}/db/import.csv"
secondary_import_path = "#{Rails.root}/db/secondary_import.csv"

if File.exist?(import_path)
  data     = File.read import_path
  importer = Spree::ImportSourceFile.new data: data, file_name: import_path, mime: "text/csv"
  importer.import!
end

if File.exist?(secondary_import_path)
  data     = File.read secondary_import_path
  importer = Spree::ImportSourceFile.new data: data, file_name: secondary_import_path, mime: "text/csv"
  importer.import!
end
