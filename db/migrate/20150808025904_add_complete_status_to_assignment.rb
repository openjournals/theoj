class AddCompleteStatusToAssignment < ActiveRecord::Migration

  def change
    add_column :assignments, :reviewer_accept, :boolean, null:true, default:nil
  end

end
