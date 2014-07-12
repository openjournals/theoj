class AddAssignedUserToPaper < ActiveRecord::Migration
  def change
    add_column :papers, :fao_id, :integer

    add_index :papers, ["fao_id"]
  end
end
