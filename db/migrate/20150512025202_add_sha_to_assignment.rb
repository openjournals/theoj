class AddShaToAssignment < ActiveRecord::Migration

  def change
    add_column :assignments, :sha, :string

    reversible do |dir|
      dir.up do
        Assignment.find_each do |a|
          a.update_attributes!(sha:SecureRandom.hex)
        end
      end
    end

    change_column_null :assignments, :sha, false
    add_index     :assignments, ["sha"]
  end

end
