module SpreeImporter
  module Exporters
    class Product
      include SpreeImporter::Exporters::Base

      # static
      def headers(_)
        %w[ sku name price available_on description ]
      end

      def append(row, product)
        headers(product).each do |h|
          row[h] = product.send h
        end
      end
    end
  end
end
