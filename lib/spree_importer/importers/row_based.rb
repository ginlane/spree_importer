module SpreeImporter
  module Importers
    module RowBased
      extend ActiveSupport::Concern
      module ClassMethods
        def target(klass)
          define_method :target do
            klass
          end
        end

        def import_attributes(*args)
          define_method :import_attributes do
            args
          end
        end
      end

      def each_instance(headers, csv)
        instances = [ ]
        csv.each do |row|
          i = target.new do |instance|
            import_attributes.each do |attr|
              instance.send "#{attr}=", val(headers, row, attr)
            end
          end
          instances << i
          yield i, row
        end
        instances
      end

      def val(headers, row, key)
        row[headers[key].raw]
      end

    end
  end
end
