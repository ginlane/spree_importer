class AddGoogleExpiresInToSpreeUsers < ActiveRecord::Migration
  def change
    add_column :spree_users, :google_expires_at, :datetime
  end
end
