module SpreeImporter

  class << self
    def config
      @config ||= Config.new
      yield @config if block_given?
      @config
    end
  end

  class Config
    attr_accessor :columns
  end
end
