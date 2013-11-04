module Spree
  module Admin
    ProductsController.class_eval do
      def export
        respond_to do |format|
          format.csv do
            self.response_body = SpreeImporter::Exporter.new search: search
          end
        end
      end

      protected
      def search
        return :dummy unless Spree::Product.exists?

        if params[:q]
          params[:q][:deleted_at_null] ||= "1"
          params[:q][:s]               ||= "name asc"
          params[:q]
        end
      end
    end
  end
end
