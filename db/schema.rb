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

ActiveRecord::Schema[7.2].define(version: 2024_10_28_132307) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artists", force: :cascade do |t|
    t.string "sptf_artist_id"
    t.bigint "user_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_artists_on_user_id"
  end

  create_table "contexts", force: :cascade do |t|
    t.string "name"
    t.float "latitude"
    t.float "longitude"
    t.bigint "user_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_contexts_on_user_id"
  end

  create_table "genders", force: :cascade do |t|
    t.string "sptf_gender_id"
    t.bigint "user_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_genders_on_user_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.string "sptf_playlist_id"
    t.bigint "user_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_playlists_on_user_id"
  end

  create_table "rated_tracks", force: :cascade do |t|
    t.string "sptf_track_id", null: false
    t.integer "rate"
    t.bigint "user_id", null: false
    t.bigint "context_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["context_id"], name: "index_rated_tracks_on_context_id"
    t.index ["user_id"], name: "index_rated_tracks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "sptf_user_id"
    t.string "sptf_access_token"
    t.string "sptf_token_type"
    t.integer "sptf_expires_in"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "artists", "users"
  add_foreign_key "contexts", "users"
  add_foreign_key "genders", "users"
  add_foreign_key "playlists", "users"
  add_foreign_key "rated_tracks", "contexts"
  add_foreign_key "rated_tracks", "users"
end
