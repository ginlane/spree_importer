class CreateSpreeImports < ActiveRecord::Migration
  def change
    create_table :spree_imports do |t|
      t.string :targets
      t.string :arguments
      t.text   :records_created

      t.text   :csv
      t.timestamps
    end
  end
end
