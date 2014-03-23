class AddStockTransferIdToImportSourceFile < ActiveRecord::Migration
  def change
    add_column :spree_stock_transfers, :batch_id, :integer
  end
end
