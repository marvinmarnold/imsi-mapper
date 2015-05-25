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

ActiveRecord::Schema.define(version: 20150525211050) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "imsi_data", force: :cascade do |t|
    t.integer  "aimsicd_threat_level"
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.decimal  "latitude_degrees",     precision: 15, scale: 10, default: 0.0
    t.decimal  "longitude_degrees",    precision: 15, scale: 10, default: 0.0
  end

  create_table "wifi_data", force: :cascade do |t|
    t.integer  "num_wifi_hotspots"
    t.decimal  "latitude_degrees",  precision: 15, scale: 10, default: 0.0
    t.decimal  "longitude_degrees", precision: 15, scale: 10, default: 0.0
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
  end

end
