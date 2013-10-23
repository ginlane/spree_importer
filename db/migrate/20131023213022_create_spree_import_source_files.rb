class CreateSpreeImportSourceFiles < ActiveRecord::Migration
  def change
    create_table :spree_import_source_files do |t|
      t.text   :data
      t.string :mime
      t.timestamps
    end
  end
end
