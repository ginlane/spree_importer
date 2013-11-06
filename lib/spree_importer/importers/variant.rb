module SpreeImporter
  module Importers
    class Variant
      include SpreeImporter::Importers::Base

      row_based

      import_attributes :sku
      unique_keys :sku

      target ::Spree::Variant

      def import(headers, csv)
        each_instance headers, csv do |instance, row|
          # product          = instance.is_master?? instance.product : master_variant(headers, row).product
          # instance.product = product

        end
      end

      def master_variant(headers, row)
        target.find_by_sku val(headers, row, "master_sku")
      end
    end
  end
end
