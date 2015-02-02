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

ActiveRecord::Schema.define(version: 20150201224917) do

  create_table "annotations", force: true do |t|
    t.integer  "user_id"
    t.integer  "paper_id"
    t.string   "state"
    t.integer  "parent_id"
    t.string   "category"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations", ["paper_id"], name: "index_annotation_paper_id", using: :btree
  add_index "annotations", ["parent_id"], name: "index_annotation_parent_id", using: :btree
  add_index "annotations", ["state"], name: "index_annotation_state", using: :btree
  add_index "annotations", ["user_id"], name: "index_annotation_user_id", using: :btree

  create_table "assignments", force: true do |t|
    t.integer  "user_id"
    t.integer  "paper_id"
    t.string   "role"
    t.integer  "assignee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assignments", ["assignee_id"], name: "index_assignment_assignee_id", using: :btree
  add_index "assignments", ["paper_id"], name: "index_assignment_paper_id", using: :btree
  add_index "assignments", ["role"], name: "index_assignment_role", using: :btree
  add_index "assignments", ["user_id"], name: "index_assignment_user_id", using: :btree

  create_table "papers", force: true do |t|
    t.integer  "user_id"
    t.string   "location"
    t.string   "state"
    t.datetime "submitted_at"
    t.string   "title"
    t.integer  "version",      default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sha"
    t.integer  "fao_id"
    t.string   "arxiv_id"
    t.text     "summary"
    t.text     "author_list"
  end

  add_index "papers", ["arxiv_id"], name: "index_papers_on_arxiv_id", using: :btree
  add_index "papers", ["fao_id"], name: "index_papers_on_fao_id", using: :btree
  add_index "papers", ["sha"], name: "index_papers_on_sha", using: :btree
  add_index "papers", ["state"], name: "index_paper_state", using: :btree
  add_index "papers", ["submitted_at"], name: "index_paper_submitted_at", using: :btree
  add_index "papers", ["user_id"], name: "index_paper_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.boolean  "admin",            default: false
    t.boolean  "editor",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.text     "extra"
    t.string   "picture"
    t.string   "sha"
  end

  add_index "users", ["admin"], name: "index_user_admin", using: :btree
  add_index "users", ["editor"], name: "index_user_editor", using: :btree
  add_index "users", ["name"], name: "index_user_name", using: :btree
  add_index "users", ["oauth_token"], name: "index_users_on_oauth_token", using: :btree
  add_index "users", ["provider"], name: "index_user_providers", using: :btree
  add_index "users", ["sha"], name: "index_users_on_sha", using: :btree
  add_index "users", ["uid"], name: "index_user_uid", using: :btree

end
