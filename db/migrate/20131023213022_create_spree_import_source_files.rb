class CreateSpreeImportSourceFiles < ActiveRecord::Migration
  def change
    create_table :spree_import_source_files do |t|
      t.text    :data, limit: 16777215
      t.integer :rows
      t.string  :file_name
      t.string  :mime
      t.text    :import_warnings
      t.text    :import_errors
      t.text    :imported_records
      t.timestamps
    end
  end
end
