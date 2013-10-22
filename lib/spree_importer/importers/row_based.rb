module SpreeImporter
  module Importers
    module RowBased
      module ClassMethods
        def import_attribute(*args)
          define_method :import_attribute do
            args
          end
        end
      end
      def import(csv)

      end
    end
  end
end
