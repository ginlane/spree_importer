require 'csv'
require 'spree_importer/config'

class SpreeImporter::Exporter
  include Enumerable
  attr_accessor :headers

  def initialize(default_options = { })
    @default_options = default_options
  end

  def export(options = @default_options)
    exporters    = get_exporters options[:exporters]
    self.headers = [ ]

    # horrifyingly inefficient. Not much way around it since
    # individual products can have arbitrary properties and
    # option_types that aren't connected to a prototype.
    each_product options[:search] do |product|
      exporters.each do |exporter|
        self.headers |= exporter.headers(product)
      end
    end

    with_csv options[:file] do |csv|
      csv << headers

      if block_given?
        yield CSV.generate_line headers
      end
      kind = options[:variants] ? :variant : :product
      send "each_#{kind}", options[:search] do |product|
        row = CSV::Row.new headers, [ ]

        exporters.each do |exporter|
          exporter.append row, product
        end

        if block_given?
          yield row.to_csv
        else
          csv << row
        end
      end
    end
  end

  def each
    export @default_options do |row|
      yield row
    end
  end

  def each_product(search, &block)
    case search
    when :all, nil
      Spree::Product.find_each &block
    when :dummy
      block.call SpreeImporter::DummyProduct.new
    else
      Spree::Product.ransack(search).result.group_by_products_id.find_each &block
    end
  end

  def each_variant(search, &block)
    each_product search do |product|
      product.variants.each &block
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
      CSV.generate({ headers: :first_row }, &block)
    else
      CSV.open(file, "wb", { headers: :first_row }, &block)
    end
  end
end
