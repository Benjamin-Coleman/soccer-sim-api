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

ActiveRecord::Schema.define(version: 20170910222512) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "competitions", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fixtures", force: :cascade do |t|
    t.integer "home_team_id"
    t.integer "away_team_id"
    t.integer "goals_home"
    t.integer "goals_away"
    t.string "status"
    t.integer "competition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "predictions", force: :cascade do |t|
    t.integer "fixture_id"
    t.float "home_goals_0"
    t.float "home_goals_1"
    t.float "home_goals_2"
    t.float "home_goals_3"
    t.float "home_goals_4"
    t.float "home_goals_5"
    t.float "away_goals_0"
    t.float "away_goals_1"
    t.float "away_goals_2"
    t.float "away_goals_3"
    t.float "away_goals_4"
    t.float "away_goals_5"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "team_competitions", force: :cascade do |t|
    t.integer "team_id"
    t.integer "competition_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "crest_url"
    t.string "short_name"
  end

end
