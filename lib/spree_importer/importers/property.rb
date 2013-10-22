module SpreeImporter
  module Importers
    class Property
      include SpreeImporter::Importers::Base

      attr_accessor :property_name

      def import(headers, csv)
        property              = Spree::Property.new
        property_header       = headers[property_name.parameterize]
        property.name         = property_header.option || property_header.sanitized
        property.presentation = property_name
        property
      end
    end
  end
end
