module SpreeImporter
  module Exporters
    class Property
      include SpreeImporter::Exporters::Base
      header_attrs [ :name, :presentation ]
      product_attr :properties

      def append(row, product)
        headers(product).each do |h|
          key      = Field.new(h).sanitized
          row[key] = product.property(Field.new(h).sanitized)
        end
      end
    end
  end
end
