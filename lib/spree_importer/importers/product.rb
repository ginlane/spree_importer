module SpreeImporter
  module Importers
    class Product
      include SpreeImporter::Importers::Base

      row_based
      import_attributes :sku, :name, :price
      target Spree::Product

      def import(headers, csv)
        each_instance headers, csv do |product, row|
          # options
          # properties
          # prototype
          # save
        end
      end
    end
  end
end
