module SpreeImporter
  module Importers
    class Product
      include SpreeImporter::Importers::Base

      row_based

      import_attributes :sku, :name, :price, :available_on, :description

      target ::Spree::Product

      def import(headers, csv)
        each_instance headers, csv do |product, row|
          # for safety we're skipping and warning on products
          if Spree::Variant.exists? sku: product.sku
            self.warnings << "Duplicate product for sku #{product.sku}, skipping import"
            next
          end

          category  = Field.new(val(headers, row, "category")).sanitized
          prototype = Spree::Prototype.find_by_name category
          shipping  = val headers, row, "shipping"

          if shipping.nil?
            shipping = Spree::ShippingCategory.find_by_name "Default"
          else
            shipping = Spree::ShippingCategory.find_by_name shipping
          end

          unless prototype.nil?
            product.prototype_id         = prototype.id
            product.shipping_category_id = shipping.id
            option_types                 = prototype.option_types
            properties                   = prototype.properties
            option_values_hash           = { }

            option_types.each do |ot|
              field   = val headers, row, ot.name
              field ||= val headers, row, ot.presentation
              if field
                fields                    = field.split(",").map{|f| Field.new(f).sanitized }
                option_values_hash[ot.id] = Spree::OptionValue.where(name: fields).map &:id
              end
            end

            product.option_values_hash = option_values_hash

            product.save!

            properties.each do |prop|
              value = val headers, row, prop.name
              if value
                product.set_property prop.name, value
              end
            end

          end
        end
      end

    end
  end
end
