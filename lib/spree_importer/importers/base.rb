module SpreeImporter
  module Importers
    module Base
      extend ActiveSupport::Concern
      module ClassMethods
        def row_based
          include SpreeImporter::Importers::RowBased
        end

        def column_based
          include SpreeImporter::Importers::ColumnBased
        end

        def header_based
          include SpreeImporter::Importers::HeaderBased
        end
      end
    end
  end
end
