module SpreeImporter
  module Importers
    class Option
      include SpreeImporter::Importers::Base

      attr_accessor :option_name, :delimiter

      def import(headers, csv)
        option_type              = Spree::OptionType.new
        values                   = [ ]
        option_header            = headers[option_name.parameterize]
        option_type.name         = option_header.option || option_header.sanitized
        option_type.presentation = option_name

        csv.each do |row|
          field = val headers, row, option_name.parameterize
          values << field.split(delimiter).map{ |f| Field.new f } if field
        end

        option_type.option_values = values.flatten.uniq.map do |value|
          Spree::OptionValue.new do |option_value|
            option_value.name         = value.sanitized
            option_value.presentation = value.raw
          end
        end

        option_type
      end

      def delimiter
        @delimiter ||= ","
      end
    end
  end
end
