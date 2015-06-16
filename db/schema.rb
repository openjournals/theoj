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

ActiveRecord::Schema.define(version: 20150616041205) do

  create_table "annotations", force: :cascade do |t|
    t.integer  "assignment_id", limit: 4
    t.integer  "paper_id",      limit: 4
    t.string   "state",         limit: 255
    t.integer  "parent_id",     limit: 4
    t.text     "body",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "page",          limit: 4
    t.float    "xStart",        limit: 24
    t.float    "yStart",        limit: 24
    t.float    "xEnd",          limit: 24
    t.float    "yEnd",          limit: 24
  end

  add_index "annotations", ["assignment_id"], name: "index_annotations_on_assignment_id", using: :btree
  add_index "annotations", ["paper_id"], name: "index_annotation_paper_id", using: :btree
  add_index "annotations", ["parent_id"], name: "index_annotation_parent_id", using: :btree
  add_index "annotations", ["state"], name: "index_annotation_state", using: :btree

  create_table "assignments", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "paper_id",   limit: 4
    t.string   "role",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sha",        limit: 255,                 null: false
    t.boolean  "public",     limit: 1,   default: false, null: false
    t.boolean  "completed",  limit: 1,   default: false, null: false
  end

  add_index "assignments", ["paper_id"], name: "index_assignment_paper_id", using: :btree
  add_index "assignments", ["role"], name: "index_assignment_role", using: :btree
  add_index "assignments", ["sha"], name: "index_assignments_on_sha", using: :btree
  add_index "assignments", ["user_id"], name: "index_assignment_user_id", using: :btree

  create_table "papers", force: :cascade do |t|
    t.integer  "submittor_id", limit: 4
    t.string   "location",     limit: 255
    t.string   "state",        limit: 255
    t.string   "title",        limit: 255
    t.integer  "version",      limit: 4,     default: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sha",          limit: 255
    t.string   "arxiv_id",     limit: 255
    t.text     "summary",      limit: 65535
    t.text     "author_list",  limit: 65535
  end

  add_index "papers", ["arxiv_id", "version"], name: "index_papers_on_arxiv_id_and_version", unique: true, using: :btree
  add_index "papers", ["sha"], name: "index_papers_on_sha", unique: true, using: :btree
  add_index "papers", ["state"], name: "index_paper_state", using: :btree
  add_index "papers", ["submittor_id"], name: "index_papers_on_submittor_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider",         limit: 255
    t.string   "uid",              limit: 255
    t.string   "name",             limit: 255
    t.boolean  "admin",            limit: 1,     default: false
    t.boolean  "editor",           limit: 1,     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "oauth_token",      limit: 255
    t.datetime "oauth_expires_at"
    t.text     "extra",            limit: 65535
    t.string   "picture",          limit: 255
    t.string   "sha",              limit: 255
    t.string   "email",            limit: 255
  end

  add_index "users", ["admin"], name: "index_user_admin", using: :btree
  add_index "users", ["editor"], name: "index_user_editor", using: :btree
  add_index "users", ["name"], name: "index_user_name", using: :btree
  add_index "users", ["oauth_token"], name: "index_users_on_oauth_token", using: :btree
  add_index "users", ["provider"], name: "index_user_providers", using: :btree
  add_index "users", ["sha"], name: "index_users_on_sha", using: :btree
  add_index "users", ["uid"], name: "index_user_uid", using: :btree

  add_foreign_key "annotations", "annotations", column: "parent_id", on_delete: :cascade
  add_foreign_key "annotations", "assignments"
  add_foreign_key "annotations", "papers", on_delete: :cascade
  add_foreign_key "assignments", "papers", on_delete: :cascade
  add_foreign_key "assignments", "users"
  add_foreign_key "papers", "users", column: "submittor_id", on_delete: :cascade
end
