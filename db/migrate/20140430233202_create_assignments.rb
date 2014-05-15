class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.integer :user_id
      t.integer :paper_id
      t.string :role
      t.integer :assignee_id
      t.timestamps
    end
    
    add_index "assignments", ["user_id"], :name => "index_assignment_user_id"
    add_index "assignments", ["paper_id"], :name => "index_assignment_paper_id"    
    add_index "assignments", ["role"], :name => "index_assignment_role"    
    add_index "assignments", ["assignee_id"], :name => "index_assignment_assignee_id"    
  end
end