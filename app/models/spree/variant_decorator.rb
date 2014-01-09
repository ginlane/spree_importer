Spree::Variant.class_eval do
  delegate_belongs_to :product, :properties, :property, :option_types, :taxons, :sku_pattern

  belongs_to :import_source_file, foreign_key: :batch_id

  def master_sku
    is_master?? sku : product.master.sku
  end

  def generate_sku!
    return if !sku.blank? || is_master?
    product.set_sku self
    save!
  end
end
