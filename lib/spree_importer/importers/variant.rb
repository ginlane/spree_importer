module SpreeImporter
  module Importers
    class Variant
      include SpreeImporter::Importers::Base

      row_based

      import_attributes :sku
      unique_keys :sku

      target ::Spree::Variant

      def import(headers, csv)
        return unless headers["master_sku"]

        each_instance headers, csv do |instance, row|
          if instance.new_record?
            product          = master_variant(headers, row).product
            instance.product = product

            instance.option_types.each do |type|
              if field = val(headers, row, type.name)
                instance.option_values << type.option_values.select{|v| v.name == Field.new(field).key }.first
              end
            end
          end

          instance.save! # create stock item
          stock_headers(headers, row) do |location, value|
            if value.nil?
              instance.destroy
            else
              stock_item = location.stock_items.where(variant_id: instance.id).first
              stock_item.update_column :count_on_hand, value
            end
          end
        end
      end

      def master_variant(headers, row)
        target.find_by_sku val(headers, row, "master_sku")
      end

      # stock headers are in the format (location)quantity if there is
      # only one location the header can be just "quantity", however
      # if there are more than one the location needs to be specified
      # for _each header_.
      def stock_headers(headers, row)
        headers.values.each do |header|
          if header =~ /quantity/
            location = locations[header.option || "Default"]
            yield location, val(headers, row, header.key) unless location.nil?
          end
        end
      end

      def locations
        @locations ||= Spree::StockLocation.all.inject({ }) { |acc, l| acc[l.name] = l; acc }
      end
    end
  end
end
