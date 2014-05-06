module SpreeImporter
  module Importers
    class Taxonomy
      include SpreeImporter::Importers::Base

      target ::Spree::Taxonomy

      def import(headers, csv)
        taxon_header = headers["category"]

        return if taxon_header.nil?

        taxonomies   = [ ]
        if SpreeImporter.config.progress_logging_enabled
          pbar = ::ProgressBar. create(title:self.class.name.demodulize.pluralize, total:csv.size)
        end
        csv.each do |row|
          pbar.increment if SpreeImporter.config.progress_logging_enabled
          if value = row[taxon_header.key]
            next if value == '--'

            value.split(delimiter).each do |heirarchy|
              heirarchy = heirarchy.split(sep).map &:strip

              taxonomy  = ::Spree::Taxonomy.find_or_create_by name: heirarchy.shift
              heirarchy.inject(taxonomy.root) do |taxon, sub|
                taxon.children.where(name: sub).first_or_create
              end

              taxonomies << taxonomy
            end
          end
        end
        taxonomies.uniq
        pbar.finish if SpreeImporter.config.progress_logging_enabled
      end

      def delimiter
        SpreeImporter.config.delimiter
      end
      def sep
        SpreeImporter.config.taxon_separator
      end
    end
  end
end
