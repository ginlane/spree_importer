Spree::Variant.class_eval do
  delegate_belongs_to :product, :properties, :property, :option_types

  def master_sku
    is_master?? sku : product.master.sku
  end

  def generate_sku!
    return if sku || is_master?

    option_values.sort_by! :position
    self.sku = [ master_sku, option_values.map(&:name) ].flatten.join("-").upcase
    save!
  end
end
