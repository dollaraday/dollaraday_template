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

ActiveRecord::Schema.define(version: 20150730031818) do

  create_table "audits", force: true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes", limit: 16777215
    t.integer  "version",                          default: 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",                    default: 0
    t.integer  "attempts",                    default: 0
    t.text     "handler",    limit: 16777215
    t.text     "last_error", limit: 16777215
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "donation_nonprofits", force: true do |t|
    t.integer  "donation_id"
    t.integer  "nonprofit_id"
    t.date     "donation_on"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "donation_nonprofits", ["donation_id", "nonprofit_id"], name: "index_donation_nonprofits_on_donation_id_and_nonprofit_id", using: :btree
  add_index "donation_nonprofits", ["nonprofit_id", "donation_id"], name: "index_donation_nonprofits_on_nonprofit_id_and_donation_id", using: :btree

  create_table "donations", force: true do |t|
    t.string   "guid"
    t.integer  "donor_id"
    t.integer  "donor_card_id"
    t.string   "nfg_charge_id"
    t.string   "stripe_charge_id"
    t.decimal  "amount",           precision: 8, scale: 2, default: 0.0
    t.decimal  "added_fee",        precision: 8, scale: 2, default: 0.0
    t.decimal  "total",            precision: 8, scale: 2
    t.decimal  "total_minus_fee",  precision: 8, scale: 2
    t.string   "last_failure"
    t.datetime "scheduled_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.datetime "executed_at"
    t.datetime "cancelled_at"
    t.datetime "disputed_at"
    t.datetime "refunded_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "donor_cards", force: true do |t|
    t.integer  "donor_id"
    t.string   "nfg_cof_id"
    t.string   "stripe_card_id"
    t.boolean  "is_active"
    t.string   "name"
    t.string   "email"
    t.string   "ip_address"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "donors", force: true do |t|
    t.string   "guid"
    t.integer  "subscriber_id"
    t.integer  "gift_id"
    t.string   "nfg_donor_token"
    t.string   "stripe_customer_id"
    t.boolean  "is_anonymous",       default: false
    t.boolean  "add_fee",            default: false
    t.string   "public_name"
    t.date     "started_on"
    t.date     "finished_on"
    t.datetime "failed_at"
    t.datetime "cancelled_at"
    t.datetime "uncancelled_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "emails", force: true do |t|
    t.integer  "newsletter_id"
    t.integer  "subscriber_id"
    t.string   "to"
    t.string   "mailer"
    t.string   "mailer_method"
    t.datetime "sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "favorites", force: true do |t|
    t.integer  "subscriber_id"
    t.integer  "nonprofit_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gifts", force: true do |t|
    t.integer  "giver_subscriber_id"
    t.string   "giver_email"
    t.string   "giver_name"
    t.string   "recipient_email"
    t.string   "recipient_name"
    t.string   "message"
    t.integer  "original_months_remaining"
    t.integer  "months_remaining"
    t.date     "start_on"
    t.date     "finish_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "converted_to_recipient",    default: false
  end

  create_table "metrics", force: true do |t|
    t.string   "key"
    t.decimal  "value",      precision: 10, scale: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "newsletters", force: true do |t|
    t.integer  "nonprofit_id"
    t.text     "donor_generated",      limit: 16777215
    t.text     "subscriber_generated", limit: 16777215
    t.datetime "donors_sent_at"
    t.datetime "subscribers_sent_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nonprofits", force: true do |t|
    t.string   "name"
    t.string   "nfg_name"
    t.text     "description",        limit: 16777215
    t.string   "blurb"
    t.string   "website_url"
    t.string   "slug"
    t.date     "featured_on"
    t.string   "ein"
    t.boolean  "is_public",                           default: false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "twitter"
  end

  add_index "nonprofits", ["ein"], name: "index_nonprofits_on_ein", using: :btree
  add_index "nonprofits", ["slug"], name: "index_nonprofits_on_slug", using: :btree

  create_table "payouts", force: true do |t|
    t.integer  "nonprofit_id"
    t.integer  "user_id"
    t.decimal  "amount",       precision: 8, scale: 2
    t.datetime "payout_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscribers", force: true do |t|
    t.string   "guid"
    t.string   "email"
    t.string   "name"
    t.string   "ip_address"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.string   "auth_token"
    t.datetime "subscribed_at"
    t.datetime "unsubscribed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "subscribers", ["auth_token"], name: "index_subscribers_on_auth_token", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email",                  default: "", null: false
    t.boolean  "is_admin"
    t.string   "encrypted_password",     default: "", null: false
    t.integer  "sign_in_count",          default: 0
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
