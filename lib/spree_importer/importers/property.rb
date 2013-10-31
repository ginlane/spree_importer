module SpreeImporter
  module Importers
    class Property
      include SpreeImporter::Importers::Base

      target ::Spree::Property

      attr_accessor :property_name

      def import(headers, csv)
        property_header       = headers[property_name.parameterize]
        names                 = [ property_header.option, property_header.sanitized ].compact
        property              = fetch_instance name: names
        property.name         = property_header.option || property_header.sanitized
        property.presentation = property_header.label
        property
      end
    end
  end
end
