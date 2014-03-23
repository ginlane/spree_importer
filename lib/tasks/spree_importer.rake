

namespace :csv do
  task :export, [:file] => [:environment] do |t, args|
    file = args[:file] || Rails.root.join('db/export.csv')
    puts file
    SpreeImporter.config.progress_logging_enabled = true
    SpreeImporter::Exporter.new(target: :variant, file: file).export 
  end
  task :import, [:file] => [:environment] do |t, args|
    import_path = args[:file] || "#{Rails.root}/db/import.csv" 
    if File.exist?(import_path)
      data     = File.read import_path
      SpreeImporter.config.progress_logging_enabled = true
      importer = Spree::ImportSourceFile.new data: data, file_name: import_path, mime: "text/csv"
      importer.save
      importer.import!
    end    
  end
end