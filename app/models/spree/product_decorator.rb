module Spree
  Product.class_eval do

    belongs_to :import_source_file, foreign_key: :batch_id

    def set_sku(variant)
      pattern         = sku_pattern.blank?? SpreeImporter.config.default_sku : sku_pattern
      options         = variant.option_values.map {|v| [ v.option_type.name, v ] }
      @interpolator   = SpreeImporter::SkuInterpolator.new(pattern)
      variant.update sku: @interpolator.to_sku(master.sku, options)
      variant.sku
    end

    def reset_variants_skus
      variants.map do |v|
        set_sku(v)
      end
    end
  end
end
