# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140212023345) do

  create_table "comments", force: true do |t|
    t.integer  "user_id"
    t.integer  "paper_id"
    t.string   "state"
    t.integer  "parent_id"
    t.string   "category"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["paper_id"], name: "index_comment_paper_id", using: :btree
  add_index "comments", ["parent_id"], name: "index_comment_parent_id", using: :btree
  add_index "comments", ["state"], name: "index_comment_state", using: :btree
  add_index "comments", ["user_id"], name: "index_comment_user_id", using: :btree

  create_table "papers", force: true do |t|
    t.integer  "user_id"
    t.string   "location"
    t.string   "state"
    t.datetime "submitted_at"
    t.string   "title"
    t.integer  "version",      default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "papers", ["state"], name: "index_paper_state", using: :btree
  add_index "papers", ["submitted_at"], name: "index_paper_submitted_at", using: :btree
  add_index "papers", ["user_id"], name: "index_paper_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.text     "extra"
    t.string   "picture"
  end

  add_index "users", ["name"], name: "index_user_name", using: :btree
  add_index "users", ["oauth_token"], name: "index_users_on_oauth_token", using: :btree
  add_index "users", ["provider"], name: "index_user_providers", using: :btree
  add_index "users", ["uid"], name: "index_user_uid", using: :btree

end
