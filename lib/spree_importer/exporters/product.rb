module SpreeImporter
  module Exporters
    class Product
      include SpreeImporter::Exporters::Base

      def headers(product)
        # static
        %w[ sku name price available_on description ]
      end

      def append(row, product)
        headers(product).inject(row) do |acc, h|
          acc << [ h, product.send(h) ]
          acc
        end
      end
    end
  end
end
