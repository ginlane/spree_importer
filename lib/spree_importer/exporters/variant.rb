module SpreeImporter
  module Exporters
    class Variant < Product
      default_exporters  :variant, :option, :property, :taxonomy

      def headers(variant)
        super(variant).unshift("master_sku") + Spree::StockLocation.all.map do |loc|
          Field.to_field_string "quantity", option: loc.name
        end
      end

      def append(row, variant)
        super row, variant
        row["master_sku"]  = variant.master_sku
        variant.stock_items.each do |si|
          key      = Field.to_field_string "quantity", option: si.stock_location.name
          row[key] = si.count_on_hand
        end
      end

      def each_export_item(search, &block)
        super search do |product|
          product.variants.each &block
        end
      end
    end
  end
end
