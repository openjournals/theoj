class AddShaToUser < ActiveRecord::Migration
  def change
    add_column :users, :sha, :string

    add_index :users, ["sha"]
  end
end
