module SpreeImporter
  module Exporters
    # define a target exporter with finder strategies
    module Target
      extend ActiveSupport::Concern

      module ClassMethods
        def fixed_headers
          define_method :fixed_headers? do
            true
          end
        end
        # reject incompatible exporters
        def rejects(*exporters)
          define_method :rejects do
            exporters.map &:to_s
          end
          define_method :default_exporters do
            [ ]
          end
        end

        def default_exporters(*exporters)
          define_method :rejects do
            [ ]
          end
          define_method :default_exporters do
            exporters
          end
        end
      end

      def fixed_headers?
        false
      end

      def get_exporters(exporter_names)
        exporters = SpreeImporter.config.exporters

        return exporters.slice(*default_exporters).values.map(&:new) unless default_exporters.empty?

        exporters = exporters.slice(*exporter_names) unless exporter_names.blank?

        exporters.reject { |k, _ | rejects.include? k.to_s }.values.map(&:new)
      end

      def each_export_item(search, &block)
        raise Exception.new <<-EOS
[Abstract Method not implemented] This method should yield each target item to the passed block.
e.g.

def each_export_item(search, &block)
  Spree::TargetModel.where(search).find_each &block
end

        EOS
      end
    end
  end
end
