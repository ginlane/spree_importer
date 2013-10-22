module SpreeImporter

  class << self
    def config
      @config ||= Config.new
      yield @config if block_given?
      @config
    end
  end

  class Config
    attr_accessor :importers
    def register_importer(key, klass)
      self.importers[key] = klass
    end

    def importers
      @importers ||= {
        product: SpreeImporter::Importers::Product
      }
    end
  end
end
