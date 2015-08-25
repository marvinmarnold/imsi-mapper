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

ActiveRecord::Schema.define(version: 20150825041930) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string   "access_token"
    t.string   "name"
    t.string   "comment"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "factoids", force: :cascade do |t|
    t.string   "fact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stingray_readings", force: :cascade do |t|
    t.datetime "observed_at"
    t.string   "version"
    t.decimal  "lat",          precision: 15, scale: 10, default: 0.0
    t.decimal  "long",         precision: 15, scale: 10, default: 0.0
    t.integer  "threat_level"
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
    t.string   "location"
    t.integer  "flag",                                   default: 0
    t.decimal  "med_res_lat",  precision: 15, scale: 5,  default: 0.0
    t.decimal  "med_res_long", precision: 15, scale: 5,  default: 0.0
    t.decimal  "low_res_lat",  precision: 13, scale: 3,  default: 0.0
    t.decimal  "low_res_long", precision: 13, scale: 3,  default: 0.0
    t.string   "region"
    t.string   "unique_token"
  end

end
