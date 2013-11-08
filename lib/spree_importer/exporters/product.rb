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
          next unless product.respond_to? h

          if date_column? h
            row[h]  = product.send(h).try :strftime, SpreeImporter.config.date_format
          else
            row[h]  = product.send h
          end
        end
      end

      def date_column?(column)
        SpreeImporter.config.date_columns.include? column
      end
    end
  end
end
