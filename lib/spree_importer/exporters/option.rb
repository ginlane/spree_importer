module SpreeImporter
  module Exporters
    class Option
      include SpreeImporter::Exporters::Base
      prefix       :option
      header_attrs [ :name, :presentation ]
      product_attr :option_types
      has_options

      def append(row, product)
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
