Spree::Variant.class_eval do
  delegate_belongs_to :product, :properties, :property
end
