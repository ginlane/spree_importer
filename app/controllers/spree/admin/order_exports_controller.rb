module Spree
  module Admin
    class OrderExportsController < Spree::Admin::BaseController
      before_filter :set_streaming_headers, only: [ :export ]

      def export
        respond_to do |format|
          format.csv do
            self.response_body = SpreeImporter::Exporter.new search: search, target: :order
          end
        end
      end

      protected
      def set_streaming_headers
        headers['X-Accel-Buffering'] = 'no'

        headers["Cache-Control"] ||= "no-cache"
        headers.delete("Content-Length")
      end

      def search
        return :dummy unless Spree::Order.exists?

        if params[:q]
          params[:q][:deleted_at_null] ||= "1"
          params[:q][:s]               ||= "name asc"
          params[:q]
        end
      end

    end
  end
end
