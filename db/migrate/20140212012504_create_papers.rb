class CreatePapers < ActiveRecord::Migration
  def change
    create_table :papers do |t|
      t.integer :user_id
      t.string :location
      t.string :state
      t.datetime :submitted_at
      t.string :title
      t.integer :version, :default => 1
      t.timestamps
    end
    
    add_index "papers", ["user_id"], :name => "index_paper_user_id"
    add_index "papers", ["state"], :name => "index_paper_state"
    add_index "papers", ["submitted_at"], :name => "index_paper_submitted_at"
  end
end
