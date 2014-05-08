module SpreeImporter
  module Importers
    class Product
      include SpreeImporter::Importers::Base

      attr_accessor :batch_id

      row_based

      import_attributes :sku_pattern, :sku, :name, :price, :available_on,
                        :description, :meta_description, :meta_keywords, :cost_price
      target ::Spree::Product

      def fetch_instance(headers, row)
        master_sku             = val headers, row, :master_sku
        obj = target.by_sku(master_sku).first

        if obj
          target.find obj.id
        else
          target.new
        end
      end

      def import(headers, csv)
        each_instance headers, csv do |product, row|

          master_sku             = val headers, row, :master_sku
          product.sku            = master_sku unless master_sku.nil?
          product.sku_pattern  ||= SpreeImporter.config.default_sku

          if product.batch_id.present? && product.batch_id != batch_id
            old_batch_ids = (product.property('Previous Batch IDs') || '').split(',')
            unless old_batch_ids.include? product.batch_id
              str = old_batch_ids.push(product.batch_id).join(',')
              product.set_property('Previous Batch IDs', str)
            end
          end

          product.batch_id        = batch_id

          if ::Spree::Variant.exists? sku: product.sku
            # product.save
            # next
          end

          unless product.shipping_category_id.present?
            shipping    = val headers, row, :shipping

            if shipping.nil?
              shipping = ::Spree::ShippingCategory.find_by_name "Default"
            else
              shipping = ::Spree::ShippingCategory.find_by_name shipping
            end

            product.shipping_category_id = shipping.id
          end

          properties, option_types     = props_and_ops_from_headers headers, row

          setup_variants product,   option_types, headers, row
          setup_properties product, properties, headers, row
          puts "SKU: #{product.sku} id: #{product.id} name: #{product.name} variants: #{product.variants.map(&:sku)} taxons: #{product.taxons.map(&:name)}"
          setup_taxonomies product, row['category']

          product.save
        end
      end

      def setup_taxonomies(product, taxonomies)
        if taxonomies
          taxon_names = taxonomies.split(SpreeImporter.config.delimiter).map do |tax|
            tax.split(SpreeImporter.config.taxon_separator).last.strip
          end.uniq

          current_taxon_names = product.taxons.map(&:name)
          removed = current_taxon_names.reject{|n| taxon_names.include? n }

          Spree::Taxon.where(name:removed).map do |t|
            product.classifications.where(taxon:t).destroy_all
          end
          new_taxons = taxon_names - current_taxon_names
          Spree::Taxon.where(name: new_taxons).each do |t|
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

        product.save

        product.master.track_inventory = false
        product.master.save
        product.master.stock_items.destroy_all

        if val headers, row, :sku
          product.variants.destroy_all
        else
          product.variants.each &:generate_sku!
        end

        product.variants_including_master.each{|v| v.update_attribute :batch_id, batch_id }
      end
    end

  end
end
