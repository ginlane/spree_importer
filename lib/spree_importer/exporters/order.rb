module SpreeImporter
  module Exporters
    class Order
      include SpreeImporter::Exporters::Base
      include SpreeImporter::Exporters::Target

      default_exporters  :order, :option, :property, :taxonomy

      def headers(order)
        %w[ number state completed_at name sku customer_name shipping_address billing_address
            shipment_state price tax subtotal total quantity ]
      end

      def append(row, line_item)
        order                   = line_item.order
        tax                     = order.adjustments.tax.first.try :amount
        row["number"]           = order.number
        row["completed_at"]     = order.completed_at
        row["state"]            = order.state
        row["name"]             = line_item.name
        row["sku"]              = line_item.sku
        row["customer_name"]    = order.shipping_address.try :full_name
        row["shipping_address"] = flat_address order.shipping_address
        row["billing_address"]  = flat_address order.billing_address
        row["shipment_state"]   = order.shipment_state
        row["price"]            = line_item.price
        row["tax"]              = '%.2f' % (order.tax_zone.tax_rates.first.try(:amount).to_f * line_item.total)
        row["subtotal"]         = line_item.amount
        row["total"]         = line_item.amount + row["tax"].to_f
        row["quantity"]         = line_item.quantity
      end

      def flat_address(address)
        [
          address.try(:address1), address.try(:address2), address.try(:city), address.try(:state)
        ].compact.join ", "
      end

      def each_export_item(search, &block)
        case search
        when :all, nil
          Spree::Order.find_each do |order|
            order.line_items.includes(:variant).each &block
          end
        else
          Spree::Order.ransack(search).result.find_each do |order|
            order.line_items.each &block
          end
        end
      end
    end
  end
end
