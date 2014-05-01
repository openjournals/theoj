class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.integer :paper_id
      t.string :state
      t.integer :parent_id
      t.string :category
      t.text :body
      t.timestamps
    end
    
    add_index "comments", ["user_id"], :name => "index_comment_user_id"
    add_index "comments", ["paper_id"], :name => "index_comment_paper_id"
    add_index "comments", ["state"], :name => "index_comment_state"
    add_index "comments", ["parent_id"], :name => "index_comment_parent_id"
  end
end
