module Spree
  module Admin
    OrdersController.class_eval do
      def export
        respond_to do |format|
          format.csv do
            self.response_body = SpreeImporter::Exporter.new search: search, target: :order
          end
        end
      end

      protected
      def search
        return :dummy unless Spree::Order.exists?

        if params[:q]
          params[:q][:deleted_at_null] ||= "1"
          params[:q][:s]               ||= "created_at desc"
          params[:q][:state_not_eq]    ||= "cart"
          params[:q]
        end
      end
    end
  end
end
