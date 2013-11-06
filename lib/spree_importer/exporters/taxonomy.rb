module SpreeImporter
  module Exporters
    class Taxonomy
      include SpreeImporter::Exporters::Base

      def headers(product)
        %w[ category ]
      end

      def append(row, product)
        row["category"] = product.taxons.map(&:pretty_name).join ","
      end
    end
  end
end
