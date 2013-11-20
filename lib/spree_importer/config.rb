module SpreeImporter

  class << self
    def config
      @config ||= Config.new
      yield @config if block_given?
      @config
    end
  end

  module AttrAccessorWithDefault
    extend ActiveSupport::Concern
    module ClassMethods
      def attr_accessor_with_default(attrs)
        attrs.each do |attr, default|
          attr_accessor attr
          define_method attr do
            instance_variable_get("@#{attr}".to_sym) || default
          end
        end
      end
    end
  end

  class Config
    include AttrAccessorWithDefault

    attr_accessor :importers, :exporters

    attr_accessor_with_default delimiter: ",",
                               date_format: "%m/%d/%Y",
                               date_columns: %w[ available_on ],
                               taxon_separator: "->",
                               default_sku: "<master>-*"


    def register_importer(key, klass)
      self.importers[key] = klass
    end

    def register_exporter(key, klass)
      self.exporters[key] = klass
    end

    def importers
      @importers ||= {
        product:    SpreeImporter::Importers::Product,
        property:   SpreeImporter::Importers::Property,
        option:     SpreeImporter::Importers::Option,
        taxonomy:   SpreeImporter::Importers::Taxonomy,
        variant:    SpreeImporter::Importers::Variant,
        prototype:  SpreeImporter::Importers::Prototype
      }.with_indifferent_access
    end

    def exporters
      @exporters ||= {
        product:   SpreeImporter::Exporters::Product,
        option:    SpreeImporter::Exporters::Option,
        property:  SpreeImporter::Exporters::Property,
        taxonomy:  SpreeImporter::Exporters::Taxonomy,
        variant:   SpreeImporter::Exporters::Variant,
        order:     SpreeImporter::Exporters::Order,
        # prototype: SpreeImporter::Exporters::Prototype
      }.with_indifferent_access
    end

  end
end
