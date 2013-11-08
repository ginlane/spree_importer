module SpreeImporter
  module Exporters
    class Taxonomy
      include SpreeImporter::Exporters::Base

      def headers(product)
        %w[ category ]
      end

      def append(row, product)
        row["category"] = product.taxons.map(&:pretty_name).join SpreeImporter.config.delimiter
        row["category"].gsub! /->/, SpreeImporter.config.taxon_separator
      end
    end
  end
end
