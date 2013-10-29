module SpreeImporter
  module Exporters
    class Option
      include SpreeImporter::Exporters::Base
      prefix       :option
      header_attrs [ :name, :presentation ]
      product_attr :option_types

      def append(row, product)
        product.option_types.inject row do |acc, type|
          acc << [ type.option_values.join(",") ]
          acc
        end
      end
    end
  end
end
