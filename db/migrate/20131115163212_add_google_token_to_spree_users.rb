class AddGoogleTokenToSpreeUsers < ActiveRecord::Migration
  def change
    add_column :spree_users, :google_token, :string
  end
end
