module SpreeImporter
  module Exporters
    class Variant < Product

      # static
      def headers(variant)
        super(variant).unshift "master_sku"
      end

      def append(row, variant)
        super row, variant
        row["master_sku"] = variant.master_sku
      end
    end
  end
end
