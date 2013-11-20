module SpreeImporter
  module Exporters
    class Product
      include SpreeImporter::Exporters::Base
      include SpreeImporter::Exporters::Target

      default_exporters :product, :option, :property, :taxonomy

      # static
      def headers(product_or_variant)
        %w[ sku name price available_on description meta_description meta_keywords cost_price ]
      end

      def append(row, product)
        headers(product).each do |h|
          next unless product.respond_to? h

          if date_column? h
            row[h] = product.send(h).try :strftime, SpreeImporter.config.date_format
          else
            row[h] = product.send h
          end
        end
      end

      def date_column?(column)
        SpreeImporter.config.date_columns.include? column
      end

      def each_export_item(search, &block)
        case search
        when :all, nil
          Spree::Product.find_each &block
        when :dummy
          block.call SpreeImporter::DummyProduct.new
        else
          Spree::Product.ransack(search).result.group_by_products_id.find_each &block
        end
      end

    end
  end
end
