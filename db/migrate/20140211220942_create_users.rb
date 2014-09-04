class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name
      t.boolean :admin, :default => false
      t.boolean :editor, :default => false

      t.timestamps
    end

    add_index "users", ["provider"], :name => "index_user_providers"
    add_index "users", ["uid"], :name => "index_user_uid"
    add_index "users", ["name"], :name => "index_user_name"
    add_index "users", ["admin"], :name => "index_user_admin"
    add_index "users", ["editor"], :name => "index_user_editor"
  end
end
