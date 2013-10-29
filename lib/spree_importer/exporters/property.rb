module SpreeImporter
  module Exporters
    class Property
      include SpreeImporter::Exporters::Base
      header_attrs [ :name, :presentation ]
      product_attr :properties

      def append(row, product)
        headers(product).inject row do |acc, h|
          acc << [ h, product.property(Field.new(h).sanitized) ]
        end
      end
    end
  end
end
