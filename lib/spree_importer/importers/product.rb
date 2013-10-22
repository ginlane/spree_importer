module SpreeImporter
  module Importers
    class Product
      include SpreeImporter::Importers::Base

      row_based
      import_attributes :sku, :name, :price, :available_on
      target Spree::Product

      def import(headers, csv)
        each_instance headers, csv do |product, row|
          category  = Field.new(val(headers, row, "category")).sanitized
          prototype = Spree::Prototype.find_by_name category
          shipping  = val headers, row, "shipping"
          shipping  = Spree::ShippingCategory.find_by_name(shipping) || Spree::ShippingCategory.find_by_name("default")

          unless prototype.nil?
            product.prototype_id         = prototype.id
            product.shipping_category_id = shipping.id
            option_types                 = prototype.option_types
            properties                   = prototype.properties
            option_values_hash           = { }

            option_types.each do |ot|
              field  = val headers, row, ot.name
              if field
                option_values_hash[ot.id] = Spree::OptionValue.where name: field.split(",").map{|f| Field.new(f).sanitized }
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
