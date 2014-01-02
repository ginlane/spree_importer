class AddBatchIdToVariant < ActiveRecord::Migration
  def change
    add_column :spree_variants, :batch_id, :integer
    add_index :spree_variants, :batch_id
  end
end
