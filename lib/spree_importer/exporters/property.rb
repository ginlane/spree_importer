module SpreeImporter
  module Exporters
    class Property
      include SpreeImporter::Exporters::Base
      header_attrs [ :name, :presentation ]
      product_attr :properties
      has_options
      prefix "property"

      def append(row, product)
        headers(product).each do |h|
          field  = Field.new h
          row[h] = product.property(field.option || field.sanitized)
        end
      end
    end
  end
end
