module SpreeImporter
  module Importers
    class Product
      include SpreeImporter::Importer
      row_based
    end
  end
end
