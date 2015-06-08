class RemoveSubmittedAtField < ActiveRecord::Migration

  def change
    remove_column :papers, :submitted_at
  end

end
