class RenameSpreadsheetFeedUrlToKey < ActiveRecord::Migration
  def change
    rename_column :spree_import_source_files, :spreadsheet_feed_url, :spreadsheet_key    
  end
end
