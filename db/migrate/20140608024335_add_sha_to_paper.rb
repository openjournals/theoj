class AddShaToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :sha, :string

    add_index :papers, ["sha"]
  end
end
