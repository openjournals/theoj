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
  end
end
