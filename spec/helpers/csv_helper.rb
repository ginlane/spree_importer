
def get_importer(path)
  base     = SpreeImporter::Importer.new
  base.read csv_path(path)
  base
end

def get_import_source_file(path)
  isf = Spree::ImportSourceFile.new data: File.read(csv_path(path))
  isf.id = 999
  isf
end

def csv_path(path)
  "#{SpreeImporter::Engine.root}/spec/fixtures/files/#{path}.csv"
end
