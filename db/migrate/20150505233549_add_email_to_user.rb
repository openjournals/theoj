class AddEmailToUser < ActiveRecord::Migration
  def change
    add_column :users, :email, :string, limit:255
  end
end
