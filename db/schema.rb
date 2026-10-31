# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_11_01_000008) do
  create_table "comments", force: :cascade do |t|
    t.integer "issue_id", null: false
    t.integer "user_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_comments_on_issue_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "events", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "issue_id"
    t.integer "user_id"
    t.string "kind", null: false
    t.text "details", default: "{}", null: false
    t.datetime "created_at", null: false
    t.index ["issue_id"], name: "index_events_on_issue_id"
    t.index ["project_id", "created_at"], name: "index_events_on_project_id_and_created_at"
    t.index ["project_id"], name: "index_events_on_project_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "issues", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "number", null: false
    t.string "kind", default: "task", null: false
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "todo", null: false
    t.string "priority", default: "medium", null: false
    t.float "position", default: 0.0, null: false
    t.integer "assignee_id"
    t.integer "reporter_id"
    t.integer "estimate"
    t.date "start_date"
    t.date "due_date"
    t.integer "sprint_id"
    t.integer "parent_id"
    t.integer "release_id"
    t.text "labels"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_issues_on_assignee_id"
    t.index ["parent_id"], name: "index_issues_on_parent_id"
    t.index ["project_id", "number"], name: "index_issues_on_project_id_and_number", unique: true
    t.index ["project_id", "status", "position"], name: "index_issues_on_project_id_and_status_and_position"
    t.index ["project_id"], name: "index_issues_on_project_id"
    t.index ["release_id"], name: "index_issues_on_release_id"
    t.index ["reporter_id"], name: "index_issues_on_reporter_id"
    t.index ["sprint_id"], name: "index_issues_on_sprint_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer "project_id", null: false
    t.integer "user_id", null: false
    t.string "role", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "user_id"], name: "index_memberships_on_project_id_and_user_id", unique: true
    t.index ["project_id"], name: "index_memberships_on_project_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "milestones", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.date "due_date"
    t.integer "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "completed_on"
    t.index ["project_id"], name: "index_milestones_on_project_id"
  end

  create_table "pages", force: :cascade do |t|
    t.integer "project_id"
    t.integer "product_id"
    t.integer "parent_id"
    t.integer "author_id"
    t.string "title", null: false
    t.string "icon"
    t.text "body"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_id"], name: "index_pages_on_author_id"
    t.index ["parent_id"], name: "index_pages_on_parent_id"
    t.index ["product_id"], name: "index_pages_on_product_id"
    t.index ["project_id"], name: "index_pages_on_project_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.text "vision"
    t.string "status", default: "active", null: false
    t.string "color", default: "#7c3aed", null: false
    t.integer "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_id"], name: "index_products_on_owner_id"
    t.index ["slug"], name: "index_products_on_slug", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.date "start_date"
    t.date "due_date"
    t.string "priority", default: "medium"
    t.string "status", default: "planning"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key", null: false
    t.string "color", default: "#7c3aed", null: false
    t.integer "lead_id"
    t.integer "product_id"
    t.index ["key"], name: "index_projects_on_key", unique: true
    t.index ["lead_id"], name: "index_projects_on_lead_id"
    t.index ["product_id"], name: "index_projects_on_product_id"
  end

  create_table "releases", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "name", null: false
    t.string "status", default: "planned", null: false
    t.date "target_date"
    t.date "released_on"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_releases_on_product_id"
  end

  create_table "sprint_snapshots", force: :cascade do |t|
    t.integer "sprint_id", null: false
    t.date "day", null: false
    t.integer "remaining_points", default: 0, null: false
    t.integer "total_points", default: 0, null: false
    t.index ["sprint_id", "day"], name: "index_sprint_snapshots_on_sprint_id_and_day", unique: true
    t.index ["sprint_id"], name: "index_sprint_snapshots_on_sprint_id"
  end

  create_table "sprints", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "name", null: false
    t.text "goal"
    t.date "start_date"
    t.date "end_date"
    t.string "status", default: "planned", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_sprints_on_project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "role", default: "member", null: false
    t.string "job_title"
    t.string "color", default: "#7c3aed", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "comments", "issues"
  add_foreign_key "comments", "users"
  add_foreign_key "events", "issues"
  add_foreign_key "events", "projects"
  add_foreign_key "events", "users"
  add_foreign_key "issues", "issues", column: "parent_id"
  add_foreign_key "issues", "projects"
  add_foreign_key "issues", "releases"
  add_foreign_key "issues", "sprints"
  add_foreign_key "issues", "users", column: "assignee_id"
  add_foreign_key "issues", "users", column: "reporter_id"
  add_foreign_key "memberships", "projects"
  add_foreign_key "memberships", "users"
  add_foreign_key "milestones", "projects"
  add_foreign_key "pages", "pages", column: "parent_id"
  add_foreign_key "pages", "products"
  add_foreign_key "pages", "projects"
  add_foreign_key "pages", "users", column: "author_id"
  add_foreign_key "products", "users", column: "owner_id"
  add_foreign_key "projects", "products"
  add_foreign_key "projects", "users", column: "lead_id"
  add_foreign_key "releases", "products"
  add_foreign_key "sprint_snapshots", "sprints"
  add_foreign_key "sprints", "projects"
end
