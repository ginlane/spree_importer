module SpreeImporter
  module Base
    extend ActiveSupport::Concern
    module ClassMethods
      def row_based
        include Importer::RowBased
      end

      def column_based
        include Importer::ColumnBased
      end

      def header_based
        include Importer::HeaderBased
      end
    end
  end
end
