

namespace :csv do
  task :export, [:file] => [:environment] do |t, args|
    file = args[:file] || Rails.root.join('db/export.csv')
    puts file
    SpreeImporter::Exporter.new(target: :variant, file: file).export 
  end
end