module SpreeImporter

  class << self
    def config
      @config ||= Config.new
      yield @config if block_given?
      @config
    end
  end

  class Config
    attr_accessor :importers, :exporters
    def register_importer(key, klass)
      self.importers[key] = klass
    end
    def register_exporter(key, klass)
      self.exporters[key] = klass
    end

    def importers
      @importers ||= {
        product:   SpreeImporter::Importers::Product,
        property:  SpreeImporter::Importers::Property,
        option:    SpreeImporter::Importers::Option,
        prototype: SpreeImporter::Importers::Prototype
      }.with_indifferent_access
    end

    def exporters
      @exporters ||= {
        product:   SpreeImporter::Exporters::Product,
        option:    SpreeImporter::Exporters::Option,
        property:  SpreeImporter::Exporters::Property,
        # prototype: SpreeImporter::Exporters::Prototype
      }.with_indifferent_access
    end

  end
end
