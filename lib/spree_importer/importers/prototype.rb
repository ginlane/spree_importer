module SpreeImporter
  module Importers
    class Prototype
      include SpreeImporter::Importers::Base

      attr_accessor :category

      def import(headers, csv)
        self.category = category.to_s.downcase
        props_and_ops = [ ]

        csv.each do |row|
          cat = Field.new val(headers, row, 'category')
          if cat.sanitized == category
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
          prototype.name         = category
          prototype.properties   = properties
          prototype.option_types = option_types
        end
      end
    end
  end
end
