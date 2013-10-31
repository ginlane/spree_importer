module SpreeImporter
  module Importers
    class Option
      include SpreeImporter::Importers::Base

      target ::Spree::OptionType

      attr_accessor :option_name, :delimiter

      def import(headers, csv)
        option_type              = fetch_instance name: option_name
        values                   = [ ]
        option_header            = headers[option_name.parameterize]

        option_type.name         = option_header.option || option_header.sanitized
        option_type.presentation = option_header.label

        csv.each do |row|
          field = val headers, row, option_name.parameterize
          values << field.split(delimiter).map{ |f| Field.new f } if field
        end

        option_type.option_values = values.flatten.uniq.map do |value|
          pos = 0
          unless option_type.option_values.map(&:name).include?(value.sanitized)
            Spree::OptionValue.new do |option_value|
              option_value.name         = value.option ||value.sanitized
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
