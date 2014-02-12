class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.string :state
      t.integer :parent_id
      t.string :category
      t.text :body
      t.timestamps
    end
  end
end
