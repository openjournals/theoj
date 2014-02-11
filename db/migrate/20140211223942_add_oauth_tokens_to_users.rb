class AddOauthTokensToUsers < ActiveRecord::Migration
  def change
    add_column :users, :oauth_token, :string
    add_column :users, :oauth_expires_at, :datetime
    add_column :users, :extra, :text
    add_column :users, :picture, :string
  end
end
