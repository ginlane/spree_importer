require 'csv'
require 'spree_importer/config'

module SpreeImporter
  class Base
    attr_accessor :csv, :headers, :errors, :warnings, :records

    def initialize
      @warnings = { }.with_indifferent_access
      @errors   = { }.with_indifferent_access
      @records  = { }.with_indifferent_access
    end

    def read(path)
      self.csv = open path
      parse
    end

    def method_missing(method, *args)
      if method =~ /(.+?)_headers/
        find_headers $1
      else
        super
      end
    end

    def find_headers(kind)
      importer = fetch_importer(kind).class
      headers.values.select { |h| importer.match_header h } unless importer.row_based?
    end

    def parse
      self.csv     = CSV.parse csv, headers: true
      self.headers = Hash[csv.headers.map.with_index.to_a].inject({ }) do |hs, (k, _)|
        h = Field.new k, is_header = true
        hs[h.sanitized] = h
        hs
      end.with_indifferent_access
    end

    def import(kind, options = { })
      create   = options.delete :create_record
      importer = fetch_importer kind

      options.each do |k, v|
        importer.send "#{k}=", v
      end

      record = importer.import headers, csv

      if create
        [ record ].flatten.each &:save

        import_errors = [ record ].flatten.inject({ }) do |acc, rec|
          acc[rec.name] = rec.errors.full_messages unless rec.valid?
          acc
        end

        unless import_errors.empty?
          errors[kind] ||= [ ]
          errors[kind]  << import_errors
        end
      end

      warnings[kind] ||= [ ]
      warnings[kind]  += importer.warnings

      records[kind]  ||= 0
      records[kind]   += [ record ].flatten.count

      record
    end

    def fetch_importer(kind)
      SpreeImporter.config.importers[kind].new
    end
  end

end
