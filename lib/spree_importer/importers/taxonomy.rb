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
              taxonomy  = ::Spree::Taxonomy.find_or_create_by name: heirarchy.shift

              heirarchy.inject(taxonomy.root) do |taxon, sub|
                sub_taxon = ::Spree::Taxon.find_or_create_by name: sub
                sub_taxon.move_to_child_of taxon
                sub_taxon
              end

              taxonomies << taxonomy
            end
          end

        end

        taxonomies.uniq
      end

      # TODO: pull these into a config
      def sep
        "->"
      end

      def delimiter
        ","
      end
    end
  end
end
