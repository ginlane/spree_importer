class AddSkuPatternToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :sku_pattern, :string
  end
end
