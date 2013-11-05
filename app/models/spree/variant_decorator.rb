Spree::Variant.class_eval do
  delegate_belongs_to :product, :properties, :property, :option_types

  def master_sku
    product.sku
  end
end
