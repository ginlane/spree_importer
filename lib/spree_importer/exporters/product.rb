module SpreeImporter
  module Exporters
    class Product
      include SpreeImporter::Exporters::Base

      # static
      def headers(product_or_variant)
        %w[ sku name price available_on description meta_description meta_keywords cost_price ]
      end

      def append(row, product)
        headers(product).each do |h|
          if h == "available_on"
            row[h]  = product.send(h).strftime "%m/%d/%Y"
          else
            row[h]  = product.send h
          end
        end
      end
    end
  end
end
