class AddSpreadsheetUrlToImportSourceFiles < ActiveRecord::Migration
  def change
    add_column :spree_import_source_files, :spreadsheet_url, :string
    add_column :spree_import_source_files, :spreadsheet_feed_url, :string
  end
end
