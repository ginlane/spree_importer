require 'csv'
require 'spree_importer/config'

class SpreeImporter::Exporter
  attr_accessor :headers
  def export(options = { })
    exporters    = get_exporters options[:exporters]
    self.headers = [ ]

    # horrifyingly inefficient. Could/should be set up to group by prototype.
    each_product options[:params] do |product|
      exporters.each do |exporter|
        self.headers |= exporter.headers(product)
      end
    end

    with_csv options[:file] do |csv|
      csv << headers
      each_product options[:params] do |product|
        row = [ ]
        exporters.each do |exporter|
          exporter.append row, product
        end
        csv << row
      end
    end
  end

  def each_product(params, &block)
    if params == :all || params.nil?
      Spree::Product.find_each &block
    else
      Spree::Product.where(params).find_each &block
    end
  end

  def get_exporters(exporters)
    if exporters.nil?
      SpreeImporter.config.exporters.values
    else
      SpreeImporter.config.exporters.slice *exporters
    end.map &:new
  end

  def with_csv(file, &block)
    if file.nil?
      CSV.generate &block
    else
      CSV.open file, "wb", &block
    end
  end
end
