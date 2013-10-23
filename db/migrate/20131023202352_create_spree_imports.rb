class CreateSpreeImports < ActiveRecord::Migration
  def change
    create_table :spree_imports do |t|
      t.references :import_source_file
      t.string :target
      t.string :arguments
      t.text   :records_created

      t.timestamps
    end
  end
end
