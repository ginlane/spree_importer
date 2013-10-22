require 'csv'
module SpreeImporter
  class Base
    attr_accessor :csv, :headers
    def read(path)
      self.csv     = open path
      self.csv     = CSV.parse @csv, headers: true
      self.headers = Hash[csv.headers.map.with_index.to_a].inject({ }) do |hdrs, (k, v)|
        h = Header.new k, v
        hs[h.sanitized] = h
        hs
      end
    end

    def import(kind)
      importer = fetch_importer kind
      csv.each do |row|

      end
    end

    def val(row, key)
      row[@headers[key].raw]
    end

    def fetch_importer(kind)
      SpreeImporter.config.importers[kind].new
    end
  end

  class Header
    attr_accessor :index, :option, :sanitized, :raw
    def initialize(header, index)
      self.raw       = header
      self.index     = index
      self.sanitized = header.parameterize "_"
      self.option    = header.scan(/\(.+?\)/).last
    end
    def option?
      !!option
    end
  end
end
