module SpreeImporter
  module Importers
    module RowBased
      extend ActiveSupport::Concern

      module ClassMethods
        def import_attributes(*args)
          define_method :import_attributes do
            args
          end
        end
        def row_based?
          true
        end
      end

      def each_instance(headers, csv)
        instances = [ ]
        csv.each do |row|
          instance = target.new
          import_attributes.each do |attr|
            if value = val(headers, row, attr)
              instance.send "#{attr}=", value
            end
          end
          instances << instance
          yield instance, row
        end
        instances
      end

    end
  end
end
