module Spree
  module Admin
    ProductsController.class_eval do
      def export
        respond_to do |format|
          format.csv do
            self.response_body = SpreeImporter::Exporter.new params: params[:q]
          end
        end
      end
    end
  end
end
