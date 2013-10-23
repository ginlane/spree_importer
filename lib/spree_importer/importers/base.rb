module SpreeImporter
  module Importers
    module Base
      extend ActiveSupport::Concern
      module ClassMethods
        def row_based
          include SpreeImporter::Importers::RowBased
        end
      end

      def val(headers, row, key)
        row[headers[key].try(:raw)].try :strip
      end

    end
  end
end
