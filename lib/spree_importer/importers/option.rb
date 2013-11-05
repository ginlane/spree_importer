module SpreeImporter
  module Importers
    class Option
      include SpreeImporter::Importers::Base

      target ::Spree::OptionType

      attr_accessor :option_name, :delimiter

      def import(headers, csv)
        option_type              = fetch_instance name: option_name
        values                   = [ ]
        option_header            = headers[option_name]
        option_type.name         = option_header.key
        option_type.presentation = option_header.label

        csv.each do |row|
          field = val headers, row, option_header.key
          values << field.split(delimiter).map{ |f| Field.new f } if field
        end

        option_type.option_values = values.flatten.uniq.map do |value|
          pos = 0
          unless option_type.option_values.map(&:name).include?(value.key)
            ::Spree::OptionValue.new do |option_value|
              option_value.name         = value.key
              option_value.presentation = value.label
              option_value.position     = (pos+=1)
            end
          end
        end.compact

        option_type
      end

      def delimiter
        @delimiter ||= ","
      end
    end
  end
end
