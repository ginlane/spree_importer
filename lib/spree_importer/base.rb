require 'csv'
require 'spree_importer/config'

module SpreeImporter
  class Base
    attr_accessor :csv, :headers
    def read(path)
      self.csv     = open path
      self.csv     = CSV.parse @csv, headers: true
      self.headers = Hash[csv.headers.map.with_index.to_a].inject({ }) do |hs, (k, v)|
        h = Field.new k, v
        hs[h.sanitized] = h
        hs
      end.with_indifferent_access
    end

    def import(kind, options = { })
      importer = fetch_importer kind
      options.each do |k, v|
        importer.send "#{k}=", v
      end
      importer.import headers, csv
    end

    def fetch_importer(kind)
      SpreeImporter.config.importers[kind].new
    end
  end

end
