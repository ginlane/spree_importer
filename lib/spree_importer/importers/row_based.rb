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

        def unique_keys(*keys)
          define_method :unique_keys do
            keys
          end
        end

        def row_based?
          true
        end
      end

      def unique_keys
        nil
      end

      def each_instance(headers, csv)
        instances = [ ]
        csv.each do |row|
          instance = fetch_instance headers, row
          import_attributes.each do |attr|
            if value = val(headers, row, attr)
              if attr == :available_on
                value = Date.strptime value, "%m/%d/%Y"
              end
              instance.send "#{attr}=", value
            end
          end
          instances << instance
          yield instance, row
        end
        instances
      end

      def fetch_instance(headers, row)
        return target.new if unique_keys.nil?

        params = unique_keys.inject({ }) do |hash, key|
          if arg = val(headers, row, key.to_s) && !arg.blank?
            hash[key] = arg
          end
          hash
        end

        return target.new if params.empty?

        target.where(params).first || target.new
      end
    end
  end
end
