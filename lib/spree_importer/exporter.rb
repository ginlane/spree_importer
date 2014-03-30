require 'csv'
require 'spree_importer/config'

class SpreeImporter::Exporter
  include Enumerable
  attr_accessor :headers

  def initialize(default_options = { target: :product })
    @default_options = default_options
  end

  def export(options = @default_options.dup)
    target_exporter = SpreeImporter.config.exporters[options.delete(:target) || :product].new
    exporters       = target_exporter.get_exporters options[:exporters]
    self.headers = [ ]


    # horrifyingly inefficient. Not much way around it since
    # individual products can have arbitrary properties and
    # option_types that aren't connected to a prototype.
    target_exporter.each_export_item options[:search] do |export_item|
      exporters.each do |exporter|
        self.headers |= exporter.headers(export_item)
      end
    end

    with_csv options[:file] do |csv|
      csv << headers

      if block_given?
        yield CSV.generate_line headers
      end

      if SpreeImporter.config.progress_logging_enabled
        pbar = ::ProgressBar.create(title:self.class.name.demodulize.pluralize)      
      end      
      target_exporter.each_export_item options[:search] do |export_item|
        if SpreeImporter.config.progress_logging_enabled
          # pbar.title = export_item.try(:name) || export_item.to_s
          if pbar.total != target_exporter.try(:count) 
            pbar.reset
            pbar.total = target_exporter.try(:count)             
          end
          pbar.increment
        end

        row = CSV::Row.new headers, [ ]
        
        exporters.each do |exporter|
          exporter.append row, export_item
        end

        if block_given?
          yield row.to_csv
        else
          csv << row
        end
      end
      pbar.stop if SpreeImporter.config.progress_logging_enabled      
    end
  end

  def each
    export @default_options do |row|
      yield row
    end
  end

  def with_csv(file, &block)
    if file.nil?
      CSV.generate({ headers: :first_row }, &block)
    else
      CSV.open(file, "wb", { headers: :first_row }, &block)
    end
  end
end
