module SpreeImporter
  module Importers
    module Base
      extend ActiveSupport::Concern
      module ClassMethods

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

      def val(headers, row, key)
        row[headers[key].try(:raw)].try :strip
      end
    end
  end
end
