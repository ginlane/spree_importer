
def importer(path)
  base     = SpreeImporter::Base.new
  csv_path = "#{SpreeImporter::Engine.root}/spec/lib/#{path}.csv"
  base.read csv_path
  base
end
