
def get_importer(path)
  base     = SpreeImporter::Importer.new
  csv_path = "#{SpreeImporter::Engine.root}/spec/fixtures/files/#{path}.csv"
  base.read csv_path
  base
end
