module SpreeImporter
  module Importers
    class Variant
      include SpreeImporter::Importers::Base

      attr_accessor :batch_id

      row_based

      import_attributes :sku
      unique_keys :sku

      target ::Spree::Variant

      def import(headers, csv)
        each_instance headers, csv do |instance, row|
          next if val(headers, row, :sku) == val(headers, row, :master_sku) ||
                  val(headers, row, :sku).blank? ||

          if instance.new_record?
            product          = master_variant(headers, row).product
            instance.product = product
            instance.option_types.each do |type|
              if f = val(headers, row, type.name)
                ov = type.option_values.select{|v| v.name == Field.new(f).key }.first
              
                # there's issue where where ov doesnt exist 
                instance.option_values << ov if ov
              end
            end
          end

          instance.batch_id = batch_id
          instance.save! # create stock item

          default_location = default_stock_location(headers,row) do |location, value|
            next if value.nil? || value == 0

            stock_transfer = 
            Spree::StockTransfer.where(
                reference:            "Batch ##{batch_id} - Initial",
                destination_location: location,
                batch_id: batch_id).first_or_create      

            stock_transfer.transfer(nil, location, {instance.id => value})                    
          end

          stock_headers(headers, row) do |location, value|  
            next if value.nil? || value == 0 

            next if value.to_i == instance.stock_items.find_by(stock_location_id:location.id).count_on_hand

            stock_transfer = 
            Spree::StockTransfer.where(
                reference:            "Batch ##{batch_id}",
                destination_location: location,
                batch_id: batch_id).first_or_create

            stock_transfer.transfer(default_location, location, {instance.id => value})
          end

          reset_headers(headers, row) do |location, value|  
            next if value.nil? #|| value == 0

            instance.stock_items.find_by(stock_location_id:location.id).set_count_on_hand(value)
          end          
        end
      end

      def master_variant(headers, row)
        target.find_by_sku val(headers, row, :master_sku)
      end

      def default_stock_location(headers,row)
        headers.values.each do |header|
          if header =~ /total/ && header.option
            stock_name = header.option 
            location = locations[stock_name]
            yield location, val(headers, row, header.key).try(:to_i) unless location.nil?
            return location
          end
        end
        return nil
      end
      # stock headers are in the format (location)quantity if there is
      # only one location the header can be just "quantity", however
      # if there are more than one the location needs to be specified
      # for _each header_.
      def stock_headers(headers, row)
        headers.values.each do |header|
          if header =~ /quantity/
            stock_name = header.option || "Default"

            locations[stock_name] ||= Spree::StockLocation.create name: stock_name, active: true
            location = locations[stock_name]

            yield location, val(headers, row, header.key).try(:to_i) unless location.nil?
          end
        end
      end
      def reset_headers(headers, row)
        headers.values.each do |header|
          if header =~ /reset/
            stock_name = header.option || "Default"

            locations[stock_name] ||= Spree::StockLocation.create name: stock_name, active: true
            location = locations[stock_name]

            yield location, val(headers, row, header.key).try(:to_i) unless location.nil?
          end
        end
      end
      def locations
        @locations ||= Spree::StockLocation.all.inject({ }) { |acc, l| acc[l.name] = l; acc }
      end
    end
  end
end
