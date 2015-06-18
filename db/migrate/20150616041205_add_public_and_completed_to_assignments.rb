class AddPublicAndCompletedToAssignments < ActiveRecord::Migration

  def change
    add_column :assignments, :public,    :boolean, null:false, default:false
    add_column :assignments, :completed, :boolean, null:false, default:false

    reversible do |dir|
      dir.up do
        Assignment.reset_column_information
        Assignment.where(role:['editor','submittor','collaborator']).find_each do |a|
          a.update_attributes(public:true)
        end
      end
    end

  end

end
