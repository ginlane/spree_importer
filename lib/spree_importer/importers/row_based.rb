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
        row_index = 0

        if SpreeImporter.config.progress_logging_enabled
          pbar = ::ProgressBar.create(title:self.class.name.demodulize.pluralize, total:csv.size)      
        end
        csv.each do |row|
          row_index += 1
          pbar.increment if SpreeImporter.config.progress_logging_enabled
          begin
            instance = fetch_instance headers, row
            import_attributes.each do |attr|
              if value = val(headers, row, attr)
                # could be pulled into some import_attribute annotations
                # or something
                if attr == :available_on
                  format = SpreeImporter.config.date_format
                  begin
                    value = Date.strptime value, format
                  rescue ArgumentError
                    message = "Invalid date `#{value}`. Expected format: `#{format}`"
                    raise SpreeImporter::ImportException.new message,
                      row: row_index,
                      column: field(headers, attr).raw,
                      column_index: field(headers, attr).index
                  end
                end
                instance.send "#{attr}=", value
              end
            end

            instances << instance
            yield instance, row

          rescue SpreeImporter::ImportException => e
            errors << e
          end
        end
        pbar.finish if SpreeImporter.config.progress_logging_enabled
        instances
      end

      def fetch_instance(headers, row)
        return target.new if unique_keys.nil?

        params = unique_keys.inject({ }) do |hash, key|
          arg       = val headers, row, key.to_s
          hash[key] = arg unless arg.blank?
          hash
        end

        return target.new if params.empty?

        target.where(params).first || target.new
      end
    end
  end
end
