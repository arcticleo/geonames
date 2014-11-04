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

ActiveRecord::Schema.define(version: 20141104043319) do

  create_table "geonames", force: true do |t|
    t.string   "name",              limit: 200
    t.string   "asciiname",         limit: 200
    t.string   "alternatenames",    limit: 10000
    t.decimal  "latitude",                        precision: 10, scale: 5
    t.decimal  "longitude",                       precision: 10, scale: 5
    t.string   "feature_class",     limit: 1
    t.string   "feature_code",      limit: 10
    t.string   "country_code",      limit: 2
    t.string   "cc2",               limit: 60
    t.string   "admin1_code",       limit: 20
    t.string   "admin2_code",       limit: 20
    t.string   "admin3_code",       limit: 20
    t.string   "admin4_code",       limit: 20
    t.integer  "population",        limit: 8
    t.integer  "elevation",         limit: 4
    t.integer  "dem",               limit: 4
    t.string   "timezone",          limit: 40
    t.datetime "modification_date"
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  create_table "postal_codes", force: true do |t|
    t.string   "country_code", limit: 2
    t.string   "postal_code",  limit: 20
    t.string   "place_name",   limit: 180
    t.string   "admin1_name",  limit: 100
    t.string   "admin1_code",  limit: 20
    t.string   "admin2_name",  limit: 100
    t.string   "admin2_code",  limit: 20
    t.string   "admin3_name",  limit: 100
    t.string   "admin3_code",  limit: 20
    t.decimal  "latitude",                 precision: 10, scale: 5
    t.decimal  "longitude",                precision: 10, scale: 5
    t.integer  "accuracy",     limit: 4
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  add_index "postal_codes", ["accuracy"], name: "index_postal_codes_on_accuracy", using: :btree
  add_index "postal_codes", ["admin1_code"], name: "index_postal_codes_on_admin1_code", using: :btree
  add_index "postal_codes", ["admin1_name"], name: "index_postal_codes_on_admin1_name", using: :btree
  add_index "postal_codes", ["admin2_code"], name: "index_postal_codes_on_admin2_code", using: :btree
  add_index "postal_codes", ["admin2_name"], name: "index_postal_codes_on_admin2_name", using: :btree
  add_index "postal_codes", ["admin3_code"], name: "index_postal_codes_on_admin3_code", using: :btree
  add_index "postal_codes", ["admin3_name"], name: "index_postal_codes_on_admin3_name", using: :btree
  add_index "postal_codes", ["latitude"], name: "index_postal_codes_on_latitude", using: :btree
  add_index "postal_codes", ["longitude"], name: "index_postal_codes_on_longitude", using: :btree
  add_index "postal_codes", ["place_name"], name: "index_postal_codes_on_place_name", using: :btree
  add_index "postal_codes", ["postal_code"], name: "index_postal_codes_on_postal_code", using: :btree

end
