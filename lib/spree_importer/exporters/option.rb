module SpreeImporter
  module Exporters
    class Option
      include SpreeImporter::Exporters::Base
      prefix       :option
      header_attrs [ :name, :presentation ]
      product_attr :option_types
      has_options

      def append(row, product)
        if product.is_a? Spree::Product
          append_product row, product
        else
          append_variant row, product
        end
      end

      def append_variant(row, variant)
        variant.option_values.each do |value|
          type     = value.option_type
          key      = Field.to_field_string type.presentation, kind: "option", option: type.name
          row[key] = Field.to_field_string value.presentation, option: value.name
        end
      end

      def append_product(row, product)
        product.option_types.each do |type|
          key      = Field.to_field_string type.presentation, kind: "option", option: type.name
          row[key] = type.option_values.map do |value|
            Field.to_field_string value.presentation, option: value.name
          end.join ","
        end
      end
    end
  end
end
