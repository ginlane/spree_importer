require 'csv'
require 'spree'
module SpreeImporter
  class Base
    attr_accessor :csv
    def read(path)
      self.csv = open path
      self.csv = CSV.parse @csv, headers: true
    end

    def parse
      p = Spree::Product.new
      csv.each do |row|
        row.headers.each do |header|
          puts header.parameterize("_")
        end
      end
    end

  end
end
