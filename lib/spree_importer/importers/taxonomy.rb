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
          pbar = ::ProgressBar.new(self.class.name.demodulize.pluralize, csv.size)      
        end
        csv.each do |row|
          pbar.inc if SpreeImporter.config.progress_logging_enabled
          if value = row[taxon_header.key]
            value.split(delimiter).each do |heirarchy|
              heirarchy = heirarchy.split(sep).map &:strip
              taxonomy  = ::Spree::Taxonomy.find_or_create_by name: heirarchy.shift
              heirarchy.inject(taxonomy.root) do |taxon, sub|
                sub_taxon = ::Spree::Taxon.where(name: sub, taxonomy: taxonomy).first_or_create
                sub_taxon.move_to_child_of taxon
                sub_taxon
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
