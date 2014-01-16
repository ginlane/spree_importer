module SpreeImporter
  module Exporters
    class Product
      include SpreeImporter::Exporters::Base
      include SpreeImporter::Exporters::Target

      default_exporters :product, :option, :property, :taxonomy

      # static
      def headers(product_or_variant)
        ['sku pattern', 'sku', 'name', 'price', 'available on', 'description', 'meta description', 'meta keywords', 'cost price']
      end

      def append(row, product)
        headers(product).each do |h|
          m = header_to_method(h)
          
          next unless product.respond_to? m

          if date_column? m
            row[h] = product.send(m).try :strftime, SpreeImporter.config.date_format
          else
            row[h] = product.send m
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
