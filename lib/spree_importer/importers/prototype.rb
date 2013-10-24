module SpreeImporter
  module Importers
    class Prototype
      include SpreeImporter::Importers::Base

      attr_accessor :prototype_name

      def import(headers, csv)
        self.prototype_name = prototype_name.to_s.downcase
        prototypes           = [ ]
        csv.each do |row|
          prototypes << Field.new(val(headers, row, prototype_name)).sanitized
        end
        prototypes.uniq.map do |prototype|
          import_prototype headers, csv, prototype
        end
      end

      def import_prototype(headers, csv, name)
        props_and_ops       = [ ]

        csv.each do |row|
          cat = Field.new val(headers, row, prototype_name)
          if cat.sanitized == name
            headers.each do |_, h|
              if val headers, row, h.sanitized
                props_and_ops << h.sanitized
                props_and_ops << h.option if h.option?
              end
            end
          end
        end


        props_and_ops.uniq!

        properties    = Spree::Property.where name: props_and_ops
        option_types  = Spree::OptionType.where name: props_and_ops

        Spree::Prototype.new do |prototype|
          prototype.name         = name
          prototype.properties   = properties
          prototype.option_types = option_types
        end
      end
    end
  end
end
