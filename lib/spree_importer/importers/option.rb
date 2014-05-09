module SpreeImporter
  module Importers
    class Option
      include SpreeImporter::Importers::Base

      target ::Spree::OptionType

      attr_accessor :option_name

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

        values = values.flatten.uniq

        values.reject! do |v|
          option_type.option_values.find_by("UPPER(name) = ?", (v.option || v.key).upcase).present?
        end

        option_type.option_values << values.map do |value|
          pos = 0
          if option_type.option_values.map(&:name).include?(value.key)
            option_type.option_values.select{|v| v.name == value.key }.first
          else
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
        SpreeImporter.config.delimiter
      end
    end
  end
end
