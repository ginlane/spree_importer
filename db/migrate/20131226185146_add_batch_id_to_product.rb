class AddBatchIdToProduct < ActiveRecord::Migration
  def change
    add_column :spree_products, :batch_id, :integer
    add_index :spree_products, :batch_id
  end
end
