module Spree
  module Admin
    OrdersController.class_eval do
      def export
        respond_to do |format|
          format.csv do
            response.headers['Content-Disposition'] = 'attachment; filename=orders_export.csv"'
            self.response_body = SpreeImporter::Exporter.new search: search, target: :order
          end
        end
      end
    end
  end
end
