class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid
      t.string :name

      t.timestamps
    end

    add_index "users", ["provider"], :name => "index_user_providers"
    add_index "users", ["uid"], :name => "index_user_uid"
    add_index "users", ["name"], :name => "index_user_name"
  end
end
