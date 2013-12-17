module SpreeImporter
  module Importers
    class Taxonomy
      include SpreeImporter::Importers::Base

      target ::Spree::Taxonomy

      def import(headers, csv)
        taxon_header = headers["category"]

        return if taxon_header.nil?

        taxonomies   = [ ]

        csv.each do |row|

          if value = val(headers, row, taxon_header.key)

            value.split(delimiter).each do |heirarchy|
              heirarchy = heirarchy.split(sep).map &:strip
              taxonomy  = find_or_create_taxonomy heirarchy.shift

              heirarchy.inject(taxonomy.root) do |taxon, sub|
                sub_taxon = find_or_create_taxon sub
                sub_taxon.move_to_child_of taxon
                sub_taxon
              end

              taxonomies << taxonomy
            end
          end

        end

        taxonomies.uniq
      end

      def delimiter
        SpreeImporter.config.delimiter
      end
      def sep
        SpreeImporter.config.taxon_separator
      end
      def find_or_create_taxon(name)
        ::Spree::Taxon.find_by_name(name) || ::Spree::Taxon.create(name: name)
      end
      def find_or_create_taxonomy(name)
        ::Spree::Taxonomy.find_by_name(name) || ::Spree::Taxonomy.create(name: name)
      end
    end
  end
end
