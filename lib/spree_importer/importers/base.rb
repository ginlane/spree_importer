 module SpreeImporter
  module Importers
    module Base
      extend ActiveSupport::Concern
      attr_writer :warnings

      module ClassMethods
        def target(klass)
          define_method :target do
            klass
          end
        end

        def match_header(h)
          h.kind == self.name.demodulize.underscore
        end

        def row_based
          include SpreeImporter::Importers::RowBased
        end

        def row_based?
          false
        end
      end

      def warnings
        @warnings ||= [ ]
      end

      def fetch_instance(params)
        instance = target.where(params).first
        if instance
          self.warnings << "Warning existing #{target} matches params #{params}"
          instance
        else
          target.new
        end
      end

      def val(headers, row, key)
        row[headers[key].try(:raw)].try :strip
      end
    end
  end
end
