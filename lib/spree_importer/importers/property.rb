module SpreeImporter
  module Importers
    class Property
      include SpreeImporter::Importers::Base

      target ::Spree::Property

      attr_accessor :property_name

      def self.match_header(h)
        h.kind.nil? && !Product.new.import_attributes.include?(h.sanitized.to_sym)
      end

      def import(headers, csv)
        property_header       = headers[property_name.parameterize]
        property              = fetch_instance name: [ property_header.option, property_header.sanitized ].compact
        property.name         = property_header.option || property_header.sanitized
        property.presentation = property_header.label
        property
      end
    end
  end
end
