module SpreeImporter
  module Exporters
    class Order
      include SpreeImporter::Exporters::Base
      include SpreeImporter::Exporters::Target

      default_exporters  :order, :option, :property, :taxonomy

      def headers(order)
        %w[ number completed_at state name sku customer_name shipping_address billing_address
            shipment_state price tax subtotal quantity ]
      end

      def append(row, line_item)
        order                   = line_item.order
        tax                     = order.adjustments.tax.first.try :amount
        row["number"]           = order.number
        row["completed_at"]     = order.completed_at.try :strftime, SpreeImporter.config.date_format
        row["name"]             = line_item.name
        row["sku"]              = line_item.sku
        row["state"]            = order.state.humanize
        row["customer_name"]    = order.shipping_address.try :full_name
        row["shipping_address"] = flat_address order.shipping_address
        row["billing_address"]  = flat_address order.billing_address
        row["shipment_state"]   = order.shipment_state
        row["price"]            = line_item.price
        row["tax"]              = tax
        row["subtotal"]         = line_item.amount
        row["quantity"]         = line_item.quantity
      end

      def flat_address(address)
        [
          address.try(:address1),
          address.try(:address2),
          address.try(:city),
          address.try(:state),
          address.try(:zipcode)
        ].compact.join ", "
      end

      def each_export_item(search, &block)
        includes = [ {order: [ :ship_address, :bill_address ] }, :variant ]
        case search
        when :all, nil
          Spree::LineItem.includes(includes).find_each do |line_item|
            block.call line_item
          end
        else
          Spree::LineItem.includes(includes).ransack(search).result.find_each do |order|
            block.call line_item
          end
        end
      end
    end
  end
end
