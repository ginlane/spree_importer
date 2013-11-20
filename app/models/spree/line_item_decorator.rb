module Spree
  LineItem.class_eval do
    delegate_belongs_to :variant, :sku, :properties, :property, :option_types, :option_values, :taxons, :name
  end
end
