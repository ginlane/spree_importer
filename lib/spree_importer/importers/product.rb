module SpreeImporter
  module Importers
    class Product
      include SpreeImporter::Importers::Base

      attr_accessor :batch_id

      row_based

      import_attributes :sku_pattern, :sku, :name, :price, :available_on,
                        :description, :meta_description, :meta_keywords, :cost_price

      target ::Spree::Product

      def import(headers, csv)
        each_instance headers, csv do |product, row|
          master_sku             = val headers, row, :master_sku
          product.sku            = master_sku unless master_sku.nil?
          product.sku_pattern  ||= SpreeImporter.config.default_sku

          product.batch_id        = batch_id



          # for safety we're skipping and warning on products that look like dups
          if ::Spree::Variant.exists? sku: product.sku
            # self.warnings << "Product exists for sku #{product.sku}, skipping product import"
            next
          end

          category    = Field.new(val(headers, row, :category)).sanitized
          shipping    = val headers, row, :shipping

          if shipping.nil?
            shipping = ::Spree::ShippingCategory.find_by_name "Default"
          else
            shipping = ::Spree::ShippingCategory.find_by_name shipping
          end
          product.shipping_category_id = shipping.id

          #previously it was before shipping category.
          setup_taxonomies(product, row['category'])

          properties                   = [ ]
          properties, option_types     = props_and_ops_from_headers headers, row

          setup_variants product,   option_types, headers, row
          setup_properties product, properties, headers, row

          product.save!
        end
      end

      def setup_taxonomies(product, taxonomies)
        if taxonomies
          taxon_names = taxonomies.split(SpreeImporter.config.delimiter).map do |tax|
            tax.split(SpreeImporter.config.taxon_separator).last.strip
          end.uniq
          Spree::Taxon.where(name: taxon_names).each do |t|
            t.products << product
          end
        end
      end

      def setup_properties(product, properties, headers, row)
        properties.each do |prop|
          value = val headers, row, prop.name
          if value
            product.set_property prop.name, value
          end
        end
      end

      def setup_variants(product, option_types, headers, row)
        option_values_hash = { }

        option_types.each do |ot|
          if field = val(headers, row, ot.name)
            fields                    = field.split(SpreeImporter.config.delimiter).map{|f| Field.new(f) }
            field_values              = (fields.map(&:key) + fields.map(&:label)).compact.uniq
            option_values_hash[ot.id] = ot.option_values.where(name: field_values).pluck(:id).uniq
          end
        end

        if option_values_hash.any?
          product.option_values_hash  = option_values_hash
        end

        product.save!
        if val headers, row, :sku
          product.variants.destroy_all
        else
          product.variants.each &:generate_sku!
        end

        product.variants.each{|v| v.update_attribute :batch_id, batch_id }
        product.master.update_attribute :batch_id, batch_id
      end
    end

  end
end
