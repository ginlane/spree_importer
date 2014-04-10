

namespace :csv do
  task :export, [:file] => [:environment] do |t, args|
    out_dir = Rails.root.join('public/exports')
    Dir.mkdir(out_dir) unless File.exists? out_dir
    file = args[:file] || "#{out_dir}/#{Time.new.strftime('%Y%m%dT%H%M')}.csv"
    SpreeImporter.config.progress_logging_enabled = true
    SpreeImporter::Exporter.new(target: :variant, file: file).export 
    puts "exported to #{file}"
  end
  task :import, [:file] => [:environment] do |t, args|
    import_path = args[:file] || "#{Rails.root}/db/import.csv" 
    if File.exist?(import_path)
      data     = File.read import_path
      SpreeImporter.config.progress_logging_enabled = true
      import = Spree::ImportSourceFile.create data: data, file_name: import_path, mime: "text/csv"
      importer = import.importer

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
      import.import_warnings  = importer.warnings
      import.imported_records = importer.records      
      import.save
    end    
  end
end