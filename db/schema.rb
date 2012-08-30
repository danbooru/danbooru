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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111101212358) do

  create_table "advertisement_hits", :force => true do |t|
    t.integer  "advertisement_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip_addr",          :limit => nil
  end

  add_index "advertisement_hits", ["advertisement_id"], :name => "index_advertisement_hits_on_advertisement_id"
  add_index "advertisement_hits", ["created_at"], :name => "index_advertisement_hits_on_created_at"

  create_table "advertisements", :force => true do |t|
    t.string   "referral_url", :limit => 1000,                    :null => false
    t.string   "ad_type",                                         :null => false
    t.string   "status",                                          :null => false
    t.integer  "hit_count",                    :default => 0,     :null => false
    t.integer  "width",                                           :null => false
    t.integer  "height",                                          :null => false
    t.boolean  "is_work_safe",                 :default => false, :null => false
    t.string   "file_name"
    t.datetime "created_at"
  end

  add_index "advertisements", ["ad_type"], :name => "index_advertisements_on_ad_type"

  create_table "amazon_backups", :force => true do |t|
    t.integer  "last_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artist_urls", :force => true do |t|
    t.integer  "artist_id",      :null => false
    t.text     "url",            :null => false
    t.text     "normalized_url", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "artist_urls", ["artist_id"], :name => "index_artist_urls_on_artist_id"
  add_index "artist_urls", ["normalized_url"], :name => "index_artist_urls_on_normalized_url"
  add_index "artist_urls", ["normalized_url"], :name => "index_artist_urls_on_normalized_url_pattern"
  add_index "artist_urls", ["url"], :name => "index_artist_urls_on_url"
  add_index "artist_urls", ["url"], :name => "index_artist_urls_on_url_pattern"

  create_table "artist_versions", :force => true do |t|
    t.integer  "artist_id"
    t.text     "name"
    t.integer  "updater_id"
    t.text     "url_string"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_active",                      :default => true,        :null => false
    t.string   "group_name"
    t.boolean  "is_banned",                      :default => false,       :null => false
    t.string   "updater_ip_addr", :limit => nil, :default => "127.0.0.1"
    t.text     "other_names",                    :default => ""
  end

  add_index "artist_versions", ["artist_id"], :name => "index_artist_versions_on_artist_id"
  add_index "artist_versions", ["updater_id"], :name => "index_artist_versions_on_updater_id"

  create_table "artists", :force => true do |t|
    t.datetime "created_at",                           :null => false
    t.text     "name",                                 :null => false
    t.datetime "updated_at",                           :null => false
    t.integer  "creator_id"
    t.boolean  "is_active",         :default => true,  :null => false
    t.string   "group_name"
    t.boolean  "is_banned",         :default => false, :null => false
    t.text     "other_names",       :default => ""
    t.tsvector "other_names_index"
  end

  add_index "artists", ["name"], :name => "index_artists_on_name", :unique => true
  add_index "artists", ["other_names_index"], :name => "index_artists_on_other_names_index"

  create_table "bans", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.text     "reason",     :null => false
    t.datetime "expires_at", :null => false
    t.integer  "banner_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "bans", ["banner_id"], :name => "index_bans_on_banner_id"
  add_index "bans", ["expires_at"], :name => "index_bans_on_expires_at"
  add_index "bans", ["user_id"], :name => "index_bans_on_user_id"

  create_table "comment_votes", :force => true do |t|
    t.integer  "comment_id",                :null => false
    t.integer  "user_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score",      :default => 0, :null => false
  end

  add_index "comment_votes", ["comment_id"], :name => "index_comment_votes_on_comment_id"
  add_index "comment_votes", ["created_at"], :name => "index_comment_votes_on_created_at"
  add_index "comment_votes", ["user_id"], :name => "index_comment_votes_on_user_id"

  create_table "comments", :force => true do |t|
    t.datetime "created_at",                               :null => false
    t.integer  "post_id",                                  :null => false
    t.integer  "creator_id"
    t.text     "body",                                     :null => false
    t.string   "ip_addr",    :limit => nil,                :null => false
    t.tsvector "body_index"
    t.integer  "score",                     :default => 0, :null => false
    t.datetime "updated_at"
  end

  add_index "comments", ["body_index"], :name => "index_comments_on_text_search_index"
  add_index "comments", ["creator_id"], :name => "index_comments_on_creator_id"
  add_index "comments", ["post_id"], :name => "index_comments_on_post_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["run_at"], :name => "index_delayed_jobs_on_run_at"

  create_table "dmails", :force => true do |t|
    t.integer  "owner_id",                         :null => false
    t.integer  "from_id",                          :null => false
    t.integer  "to_id",                            :null => false
    t.text     "title",                            :null => false
    t.text     "body",                             :null => false
    t.tsvector "message_index",                    :null => false
    t.boolean  "is_read",       :default => false, :null => false
    t.boolean  "is_deleted",    :default => false, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dmails", ["message_index"], :name => "index_dmails_on_message_index"
  add_index "dmails", ["owner_id"], :name => "index_dmails_on_owner_id"

  create_table "favorites", :force => true do |t|
    t.integer "user_id"
    t.integer "post_id"
  end

  create_table "favorites_0", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_0", ["post_id"], :name => "index_favorites_0_on_post_id"
  add_index "favorites_0", ["user_id"], :name => "index_favorites_0_on_user_id"

  create_table "favorites_1", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_1", ["post_id"], :name => "index_favorites_1_on_post_id"
  add_index "favorites_1", ["user_id"], :name => "index_favorites_1_on_user_id"

  create_table "favorites_10", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_10", ["post_id"], :name => "index_favorites_10_on_post_id"
  add_index "favorites_10", ["user_id"], :name => "index_favorites_10_on_user_id"

  create_table "favorites_11", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_11", ["post_id"], :name => "index_favorites_11_on_post_id"
  add_index "favorites_11", ["user_id"], :name => "index_favorites_11_on_user_id"

  create_table "favorites_12", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_12", ["post_id"], :name => "index_favorites_12_on_post_id"
  add_index "favorites_12", ["user_id"], :name => "index_favorites_12_on_user_id"

  create_table "favorites_13", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_13", ["post_id"], :name => "index_favorites_13_on_post_id"
  add_index "favorites_13", ["user_id"], :name => "index_favorites_13_on_user_id"

  create_table "favorites_14", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_14", ["post_id"], :name => "index_favorites_14_on_post_id"
  add_index "favorites_14", ["user_id"], :name => "index_favorites_14_on_user_id"

  create_table "favorites_15", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_15", ["post_id"], :name => "index_favorites_15_on_post_id"
  add_index "favorites_15", ["user_id"], :name => "index_favorites_15_on_user_id"

  create_table "favorites_16", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_16", ["post_id"], :name => "index_favorites_16_on_post_id"
  add_index "favorites_16", ["user_id"], :name => "index_favorites_16_on_user_id"

  create_table "favorites_17", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_17", ["post_id"], :name => "index_favorites_17_on_post_id"
  add_index "favorites_17", ["user_id"], :name => "index_favorites_17_on_user_id"

  create_table "favorites_18", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_18", ["post_id"], :name => "index_favorites_18_on_post_id"
  add_index "favorites_18", ["user_id"], :name => "index_favorites_18_on_user_id"

  create_table "favorites_19", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_19", ["post_id"], :name => "index_favorites_19_on_post_id"
  add_index "favorites_19", ["user_id"], :name => "index_favorites_19_on_user_id"

  create_table "favorites_2", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_2", ["post_id"], :name => "index_favorites_2_on_post_id"
  add_index "favorites_2", ["user_id"], :name => "index_favorites_2_on_user_id"

  create_table "favorites_20", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_20", ["post_id"], :name => "index_favorites_20_on_post_id"
  add_index "favorites_20", ["user_id"], :name => "index_favorites_20_on_user_id"

  create_table "favorites_21", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_21", ["post_id"], :name => "index_favorites_21_on_post_id"
  add_index "favorites_21", ["user_id"], :name => "index_favorites_21_on_user_id"

  create_table "favorites_22", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_22", ["post_id"], :name => "index_favorites_22_on_post_id"
  add_index "favorites_22", ["user_id"], :name => "index_favorites_22_on_user_id"

  create_table "favorites_23", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_23", ["post_id"], :name => "index_favorites_23_on_post_id"
  add_index "favorites_23", ["user_id"], :name => "index_favorites_23_on_user_id"

  create_table "favorites_24", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_24", ["post_id"], :name => "index_favorites_24_on_post_id"
  add_index "favorites_24", ["user_id"], :name => "index_favorites_24_on_user_id"

  create_table "favorites_25", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_25", ["post_id"], :name => "index_favorites_25_on_post_id"
  add_index "favorites_25", ["user_id"], :name => "index_favorites_25_on_user_id"

  create_table "favorites_26", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_26", ["post_id"], :name => "index_favorites_26_on_post_id"
  add_index "favorites_26", ["user_id"], :name => "index_favorites_26_on_user_id"

  create_table "favorites_27", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_27", ["post_id"], :name => "index_favorites_27_on_post_id"
  add_index "favorites_27", ["user_id"], :name => "index_favorites_27_on_user_id"

  create_table "favorites_28", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_28", ["post_id"], :name => "index_favorites_28_on_post_id"
  add_index "favorites_28", ["user_id"], :name => "index_favorites_28_on_user_id"

  create_table "favorites_29", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_29", ["post_id"], :name => "index_favorites_29_on_post_id"
  add_index "favorites_29", ["user_id"], :name => "index_favorites_29_on_user_id"

  create_table "favorites_3", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_3", ["post_id"], :name => "index_favorites_3_on_post_id"
  add_index "favorites_3", ["user_id"], :name => "index_favorites_3_on_user_id"

  create_table "favorites_30", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_30", ["post_id"], :name => "index_favorites_30_on_post_id"
  add_index "favorites_30", ["user_id"], :name => "index_favorites_30_on_user_id"

  create_table "favorites_31", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_31", ["post_id"], :name => "index_favorites_31_on_post_id"
  add_index "favorites_31", ["user_id"], :name => "index_favorites_31_on_user_id"

  create_table "favorites_32", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_32", ["post_id"], :name => "index_favorites_32_on_post_id"
  add_index "favorites_32", ["user_id"], :name => "index_favorites_32_on_user_id"

  create_table "favorites_33", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_33", ["post_id"], :name => "index_favorites_33_on_post_id"
  add_index "favorites_33", ["user_id"], :name => "index_favorites_33_on_user_id"

  create_table "favorites_34", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_34", ["post_id"], :name => "index_favorites_34_on_post_id"
  add_index "favorites_34", ["user_id"], :name => "index_favorites_34_on_user_id"

  create_table "favorites_35", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_35", ["post_id"], :name => "index_favorites_35_on_post_id"
  add_index "favorites_35", ["user_id"], :name => "index_favorites_35_on_user_id"

  create_table "favorites_36", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_36", ["post_id"], :name => "index_favorites_36_on_post_id"
  add_index "favorites_36", ["user_id"], :name => "index_favorites_36_on_user_id"

  create_table "favorites_37", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_37", ["post_id"], :name => "index_favorites_37_on_post_id"
  add_index "favorites_37", ["user_id"], :name => "index_favorites_37_on_user_id"

  create_table "favorites_38", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_38", ["post_id"], :name => "index_favorites_38_on_post_id"
  add_index "favorites_38", ["user_id"], :name => "index_favorites_38_on_user_id"

  create_table "favorites_39", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_39", ["post_id"], :name => "index_favorites_39_on_post_id"
  add_index "favorites_39", ["user_id"], :name => "index_favorites_39_on_user_id"

  create_table "favorites_4", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_4", ["post_id"], :name => "index_favorites_4_on_post_id"
  add_index "favorites_4", ["user_id"], :name => "index_favorites_4_on_user_id"

  create_table "favorites_40", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_40", ["post_id"], :name => "index_favorites_40_on_post_id"
  add_index "favorites_40", ["user_id"], :name => "index_favorites_40_on_user_id"

  create_table "favorites_41", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_41", ["post_id"], :name => "index_favorites_41_on_post_id"
  add_index "favorites_41", ["user_id"], :name => "index_favorites_41_on_user_id"

  create_table "favorites_42", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_42", ["post_id"], :name => "index_favorites_42_on_post_id"
  add_index "favorites_42", ["user_id"], :name => "index_favorites_42_on_user_id"

  create_table "favorites_43", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_43", ["post_id"], :name => "index_favorites_43_on_post_id"
  add_index "favorites_43", ["user_id"], :name => "index_favorites_43_on_user_id"

  create_table "favorites_44", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_44", ["post_id"], :name => "index_favorites_44_on_post_id"
  add_index "favorites_44", ["user_id"], :name => "index_favorites_44_on_user_id"

  create_table "favorites_45", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_45", ["post_id"], :name => "index_favorites_45_on_post_id"
  add_index "favorites_45", ["user_id"], :name => "index_favorites_45_on_user_id"

  create_table "favorites_46", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_46", ["post_id"], :name => "index_favorites_46_on_post_id"
  add_index "favorites_46", ["user_id"], :name => "index_favorites_46_on_user_id"

  create_table "favorites_47", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_47", ["post_id"], :name => "index_favorites_47_on_post_id"
  add_index "favorites_47", ["user_id"], :name => "index_favorites_47_on_user_id"

  create_table "favorites_48", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_48", ["post_id"], :name => "index_favorites_48_on_post_id"
  add_index "favorites_48", ["user_id"], :name => "index_favorites_48_on_user_id"

  create_table "favorites_49", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_49", ["post_id"], :name => "index_favorites_49_on_post_id"
  add_index "favorites_49", ["user_id"], :name => "index_favorites_49_on_user_id"

  create_table "favorites_5", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_5", ["post_id"], :name => "index_favorites_5_on_post_id"
  add_index "favorites_5", ["user_id"], :name => "index_favorites_5_on_user_id"

  create_table "favorites_50", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_50", ["post_id"], :name => "index_favorites_50_on_post_id"
  add_index "favorites_50", ["user_id"], :name => "index_favorites_50_on_user_id"

  create_table "favorites_51", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_51", ["post_id"], :name => "index_favorites_51_on_post_id"
  add_index "favorites_51", ["user_id"], :name => "index_favorites_51_on_user_id"

  create_table "favorites_52", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_52", ["post_id"], :name => "index_favorites_52_on_post_id"
  add_index "favorites_52", ["user_id"], :name => "index_favorites_52_on_user_id"

  create_table "favorites_53", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_53", ["post_id"], :name => "index_favorites_53_on_post_id"
  add_index "favorites_53", ["user_id"], :name => "index_favorites_53_on_user_id"

  create_table "favorites_54", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_54", ["post_id"], :name => "index_favorites_54_on_post_id"
  add_index "favorites_54", ["user_id"], :name => "index_favorites_54_on_user_id"

  create_table "favorites_55", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_55", ["post_id"], :name => "index_favorites_55_on_post_id"
  add_index "favorites_55", ["user_id"], :name => "index_favorites_55_on_user_id"

  create_table "favorites_56", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_56", ["post_id"], :name => "index_favorites_56_on_post_id"
  add_index "favorites_56", ["user_id"], :name => "index_favorites_56_on_user_id"

  create_table "favorites_57", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_57", ["post_id"], :name => "index_favorites_57_on_post_id"
  add_index "favorites_57", ["user_id"], :name => "index_favorites_57_on_user_id"

  create_table "favorites_58", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_58", ["post_id"], :name => "index_favorites_58_on_post_id"
  add_index "favorites_58", ["user_id"], :name => "index_favorites_58_on_user_id"

  create_table "favorites_59", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_59", ["post_id"], :name => "index_favorites_59_on_post_id"
  add_index "favorites_59", ["user_id"], :name => "index_favorites_59_on_user_id"

  create_table "favorites_6", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_6", ["post_id"], :name => "index_favorites_6_on_post_id"
  add_index "favorites_6", ["user_id"], :name => "index_favorites_6_on_user_id"

  create_table "favorites_60", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_60", ["post_id"], :name => "index_favorites_60_on_post_id"
  add_index "favorites_60", ["user_id"], :name => "index_favorites_60_on_user_id"

  create_table "favorites_61", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_61", ["post_id"], :name => "index_favorites_61_on_post_id"
  add_index "favorites_61", ["user_id"], :name => "index_favorites_61_on_user_id"

  create_table "favorites_62", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_62", ["post_id"], :name => "index_favorites_62_on_post_id"
  add_index "favorites_62", ["user_id"], :name => "index_favorites_62_on_user_id"

  create_table "favorites_63", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_63", ["post_id"], :name => "index_favorites_63_on_post_id"
  add_index "favorites_63", ["user_id"], :name => "index_favorites_63_on_user_id"

  create_table "favorites_64", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_64", ["post_id"], :name => "index_favorites_64_on_post_id"
  add_index "favorites_64", ["user_id"], :name => "index_favorites_64_on_user_id"

  create_table "favorites_65", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_65", ["post_id"], :name => "index_favorites_65_on_post_id"
  add_index "favorites_65", ["user_id"], :name => "index_favorites_65_on_user_id"

  create_table "favorites_66", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_66", ["post_id"], :name => "index_favorites_66_on_post_id"
  add_index "favorites_66", ["user_id"], :name => "index_favorites_66_on_user_id"

  create_table "favorites_67", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_67", ["post_id"], :name => "index_favorites_67_on_post_id"
  add_index "favorites_67", ["user_id"], :name => "index_favorites_67_on_user_id"

  create_table "favorites_68", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_68", ["post_id"], :name => "index_favorites_68_on_post_id"
  add_index "favorites_68", ["user_id"], :name => "index_favorites_68_on_user_id"

  create_table "favorites_69", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_69", ["post_id"], :name => "index_favorites_69_on_post_id"
  add_index "favorites_69", ["user_id"], :name => "index_favorites_69_on_user_id"

  create_table "favorites_7", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_7", ["post_id"], :name => "index_favorites_7_on_post_id"
  add_index "favorites_7", ["user_id"], :name => "index_favorites_7_on_user_id"

  create_table "favorites_70", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_70", ["post_id"], :name => "index_favorites_70_on_post_id"
  add_index "favorites_70", ["user_id"], :name => "index_favorites_70_on_user_id"

  create_table "favorites_71", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_71", ["post_id"], :name => "index_favorites_71_on_post_id"
  add_index "favorites_71", ["user_id"], :name => "index_favorites_71_on_user_id"

  create_table "favorites_72", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_72", ["post_id"], :name => "index_favorites_72_on_post_id"
  add_index "favorites_72", ["user_id"], :name => "index_favorites_72_on_user_id"

  create_table "favorites_73", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_73", ["post_id"], :name => "index_favorites_73_on_post_id"
  add_index "favorites_73", ["user_id"], :name => "index_favorites_73_on_user_id"

  create_table "favorites_74", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_74", ["post_id"], :name => "index_favorites_74_on_post_id"
  add_index "favorites_74", ["user_id"], :name => "index_favorites_74_on_user_id"

  create_table "favorites_75", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_75", ["post_id"], :name => "index_favorites_75_on_post_id"
  add_index "favorites_75", ["user_id"], :name => "index_favorites_75_on_user_id"

  create_table "favorites_76", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_76", ["post_id"], :name => "index_favorites_76_on_post_id"
  add_index "favorites_76", ["user_id"], :name => "index_favorites_76_on_user_id"

  create_table "favorites_77", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_77", ["post_id"], :name => "index_favorites_77_on_post_id"
  add_index "favorites_77", ["user_id"], :name => "index_favorites_77_on_user_id"

  create_table "favorites_78", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_78", ["post_id"], :name => "index_favorites_78_on_post_id"
  add_index "favorites_78", ["user_id"], :name => "index_favorites_78_on_user_id"

  create_table "favorites_79", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_79", ["post_id"], :name => "index_favorites_79_on_post_id"
  add_index "favorites_79", ["user_id"], :name => "index_favorites_79_on_user_id"

  create_table "favorites_8", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_8", ["post_id"], :name => "index_favorites_8_on_post_id"
  add_index "favorites_8", ["user_id"], :name => "index_favorites_8_on_user_id"

  create_table "favorites_80", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_80", ["post_id"], :name => "index_favorites_80_on_post_id"
  add_index "favorites_80", ["user_id"], :name => "index_favorites_80_on_user_id"

  create_table "favorites_81", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_81", ["post_id"], :name => "index_favorites_81_on_post_id"
  add_index "favorites_81", ["user_id"], :name => "index_favorites_81_on_user_id"

  create_table "favorites_82", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_82", ["post_id"], :name => "index_favorites_82_on_post_id"
  add_index "favorites_82", ["user_id"], :name => "index_favorites_82_on_user_id"

  create_table "favorites_83", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_83", ["post_id"], :name => "index_favorites_83_on_post_id"
  add_index "favorites_83", ["user_id"], :name => "index_favorites_83_on_user_id"

  create_table "favorites_84", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_84", ["post_id"], :name => "index_favorites_84_on_post_id"
  add_index "favorites_84", ["user_id"], :name => "index_favorites_84_on_user_id"

  create_table "favorites_85", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_85", ["post_id"], :name => "index_favorites_85_on_post_id"
  add_index "favorites_85", ["user_id"], :name => "index_favorites_85_on_user_id"

  create_table "favorites_86", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_86", ["post_id"], :name => "index_favorites_86_on_post_id"
  add_index "favorites_86", ["user_id"], :name => "index_favorites_86_on_user_id"

  create_table "favorites_87", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_87", ["post_id"], :name => "index_favorites_87_on_post_id"
  add_index "favorites_87", ["user_id"], :name => "index_favorites_87_on_user_id"

  create_table "favorites_88", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_88", ["post_id"], :name => "index_favorites_88_on_post_id"
  add_index "favorites_88", ["user_id"], :name => "index_favorites_88_on_user_id"

  create_table "favorites_89", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_89", ["post_id"], :name => "index_favorites_89_on_post_id"
  add_index "favorites_89", ["user_id"], :name => "index_favorites_89_on_user_id"

  create_table "favorites_9", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_9", ["post_id"], :name => "index_favorites_9_on_post_id"
  add_index "favorites_9", ["user_id"], :name => "index_favorites_9_on_user_id"

  create_table "favorites_90", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_90", ["post_id"], :name => "index_favorites_90_on_post_id"
  add_index "favorites_90", ["user_id"], :name => "index_favorites_90_on_user_id"

  create_table "favorites_91", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_91", ["post_id"], :name => "index_favorites_91_on_post_id"
  add_index "favorites_91", ["user_id"], :name => "index_favorites_91_on_user_id"

  create_table "favorites_92", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_92", ["post_id"], :name => "index_favorites_92_on_post_id"
  add_index "favorites_92", ["user_id"], :name => "index_favorites_92_on_user_id"

  create_table "favorites_93", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_93", ["post_id"], :name => "index_favorites_93_on_post_id"
  add_index "favorites_93", ["user_id"], :name => "index_favorites_93_on_user_id"

  create_table "favorites_94", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_94", ["post_id"], :name => "index_favorites_94_on_post_id"
  add_index "favorites_94", ["user_id"], :name => "index_favorites_94_on_user_id"

  create_table "favorites_95", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_95", ["post_id"], :name => "index_favorites_95_on_post_id"
  add_index "favorites_95", ["user_id"], :name => "index_favorites_95_on_user_id"

  create_table "favorites_96", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_96", ["post_id"], :name => "index_favorites_96_on_post_id"
  add_index "favorites_96", ["user_id"], :name => "index_favorites_96_on_user_id"

  create_table "favorites_97", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_97", ["post_id"], :name => "index_favorites_97_on_post_id"
  add_index "favorites_97", ["user_id"], :name => "index_favorites_97_on_user_id"

  create_table "favorites_98", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_98", ["post_id"], :name => "index_favorites_98_on_post_id"
  add_index "favorites_98", ["user_id"], :name => "index_favorites_98_on_user_id"

  create_table "favorites_99", :id => false, :force => true do |t|
    t.integer "id",      :null => false
    t.integer "user_id"
    t.integer "post_id"
  end

  add_index "favorites_99", ["post_id"], :name => "index_favorites_99_on_post_id"
  add_index "favorites_99", ["user_id"], :name => "index_favorites_99_on_user_id"

  create_table "forum_posts", :force => true do |t|
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.integer  "creator_id"
    t.text     "body",                          :null => false
    t.integer  "updater_id"
    t.tsvector "text_index"
    t.boolean  "is_deleted", :default => false, :null => false
    t.integer  "topic_id"
  end

  add_index "forum_posts", ["creator_id"], :name => "index_forum_posts_on_creator_id"
  add_index "forum_posts", ["text_index"], :name => "index_forum_posts_on_text_index"
  add_index "forum_posts", ["topic_id"], :name => "index_forum_posts_on_topic_id"
  add_index "forum_posts", ["updated_at"], :name => "index_forum_posts_on_updated_at"

  create_table "forum_topics", :force => true do |t|
    t.integer  "creator_id",                        :null => false
    t.integer  "updater_id",                        :null => false
    t.string   "title",                             :null => false
    t.integer  "response_count", :default => 0,     :null => false
    t.boolean  "is_sticky",      :default => false, :null => false
    t.boolean  "is_locked",      :default => false, :null => false
    t.tsvector "text_index",                        :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted",     :default => false, :null => false
  end

  add_index "forum_topics", ["creator_id"], :name => "index_forum_topics_on_creator_id"
  add_index "forum_topics", ["text_index"], :name => "index_forum_topics_on_text_index"

  create_table "ip_bans", :force => true do |t|
    t.integer  "creator_id",                :null => false
    t.string   "ip_addr",    :limit => nil, :null => false
    t.text     "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ip_bans", ["ip_addr"], :name => "index_ip_bans_on_ip_addr"

  create_table "janitor_trials", :force => true do |t|
    t.integer  "user_id",                       :null => false
    t.integer  "original_level",                :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "creator_id",     :default => 1, :null => false
  end

  add_index "janitor_trials", ["user_id"], :name => "index_janitor_trials_on_creator_id"

  create_table "mod_actions", :force => true do |t|
    t.integer  "creator_id"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mod_actions", ["created_at"], :name => "index_mod_actions_on_created_at"
  add_index "mod_actions", ["creator_id"], :name => "index_mod_actions_on_creator_id"

  create_table "news_updates", :force => true do |t|
    t.text     "message",    :null => false
    t.integer  "creator_id", :null => false
    t.integer  "updater_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "news_updates", ["created_at"], :name => "index_news_updates_on_created_at"

  create_table "note_versions", :force => true do |t|
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.integer  "x",                                                :null => false
    t.integer  "y",                                                :null => false
    t.integer  "width",                                            :null => false
    t.integer  "height",                                           :null => false
    t.text     "body",                                             :null => false
    t.string   "updater_ip_addr", :limit => nil,                   :null => false
    t.boolean  "is_active",                      :default => true, :null => false
    t.integer  "note_id",                                          :null => false
    t.integer  "post_id",                                          :null => false
    t.integer  "updater_id"
  end

  add_index "note_versions", ["note_id"], :name => "index_note_versions_on_note_id"
  add_index "note_versions", ["post_id"], :name => "index_note_versions_on_post_id"
  add_index "note_versions", ["updater_id"], :name => "index_note_versions_on_updater_id"
  add_index "note_versions", ["updater_ip_addr"], :name => "index_note_versions_on_updater_ip_addr"

  create_table "notes", :force => true do |t|
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "creator_id"
    t.integer  "x",                            :null => false
    t.integer  "y",                            :null => false
    t.integer  "width",                        :null => false
    t.integer  "height",                       :null => false
    t.boolean  "is_active",  :default => true, :null => false
    t.integer  "post_id",                      :null => false
    t.text     "body",                         :null => false
    t.tsvector "body_index"
  end

  add_index "notes", ["body_index"], :name => "index_notes_on_body_index"
  add_index "notes", ["creator_id"], :name => "index_notes_on_creator_id"
  add_index "notes", ["post_id"], :name => "index_notes_on_post_id"

  create_table "pool_versions", :force => true do |t|
    t.integer  "pool_id",                                        :null => false
    t.text     "post_ids",                       :default => "", :null => false
    t.integer  "updater_id"
    t.string   "updater_ip_addr", :limit => nil
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pool_versions", ["pool_id"], :name => "index_pool_versions_on_pool_id"
  add_index "pool_versions", ["updater_id"], :name => "index_pool_versions_on_updater_id"
  add_index "pool_versions", ["updater_ip_addr"], :name => "index_pool_versions_on_updater_ip_addr"

  create_table "pools", :force => true do |t|
    t.text     "name",                           :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "creator_id",                     :null => false
    t.integer  "post_count",  :default => 0,     :null => false
    t.text     "description", :default => "",    :null => false
    t.boolean  "is_active",   :default => true,  :null => false
    t.boolean  "is_deleted",  :default => false, :null => false
    t.text     "post_ids",    :default => "",    :null => false
  end

  add_index "pools", ["creator_id"], :name => "index_pools_on_creator_id"

  create_table "post_appeals", :force => true do |t|
    t.integer  "post_id"
    t.integer  "creator_id"
    t.string   "reason"
    t.string   "creator_ip_addr", :limit => nil
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_appeals", ["created_at"], :name => "index_post_appeals_on_created_at"
  add_index "post_appeals", ["creator_id"], :name => "index_post_appeals_on_creator_id"
  add_index "post_appeals", ["creator_ip_addr"], :name => "index_post_appeals_on_creator_ip_addr"
  add_index "post_appeals", ["post_id"], :name => "index_post_appeals_on_post_id"

  create_table "post_disapprovals", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "post_id",    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_disapprovals", ["post_id"], :name => "index_post_disapprovals_on_post_id"
  add_index "post_disapprovals", ["user_id"], :name => "index_post_disapprovals_on_user_id"

  create_table "post_flags", :force => true do |t|
    t.datetime "created_at",                                              :null => false
    t.integer  "post_id",                                                 :null => false
    t.text     "reason",                                                  :null => false
    t.integer  "creator_id",                                              :null => false
    t.boolean  "is_resolved",                                             :null => false
    t.string   "creator_ip_addr", :limit => nil, :default => "127.0.0.1", :null => false
    t.datetime "updated_at",                                              :null => false
  end

  add_index "post_flags", ["creator_id"], :name => "index_post_flags_on_creator_id"
  add_index "post_flags", ["creator_ip_addr"], :name => "index_post_flags_on_creator_ip_addr"
  add_index "post_flags", ["post_id"], :name => "index_post_flags_on_post_id"

  create_table "post_versions", :force => true do |t|
    t.integer  "post_id",                        :null => false
    t.text     "tags",                           :null => false
    t.integer  "updater_id"
    t.string   "updater_ip_addr", :limit => nil, :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "rating",          :limit => 1
    t.integer  "parent_id"
    t.text     "source"
  end

  add_index "post_versions", ["post_id"], :name => "index_post_versions_on_post_id"
  add_index "post_versions", ["updater_id"], :name => "index_post_versions_on_updater_id"
  add_index "post_versions", ["updater_ip_addr"], :name => "index_post_versions_on_updater_ip_addr"

  create_table "post_votes", :force => true do |t|
    t.integer  "post_id",                   :null => false
    t.integer  "user_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "score",      :default => 0, :null => false
  end

  add_index "post_votes", ["created_at"], :name => "index_post_votes_on_created_at"
  add_index "post_votes", ["post_id"], :name => "index_post_votes_on_post_id"
  add_index "post_votes", ["user_id"], :name => "index_post_votes_on_user_id"

  create_table "posts", :force => true do |t|
    t.datetime "created_at",                                            :null => false
    t.integer  "uploader_id"
    t.integer  "score",                              :default => 0,     :null => false
    t.text     "source"
    t.text     "md5",                                                   :null => false
    t.datetime "last_commented_at"
    t.string   "rating",              :limit => 1,   :default => "q",   :null => false
    t.integer  "image_width"
    t.integer  "image_height"
    t.string   "uploader_ip_addr",    :limit => nil,                    :null => false
    t.text     "tag_string",                         :default => "",    :null => false
    t.boolean  "is_note_locked",                     :default => false, :null => false
    t.integer  "fav_count",                          :default => 0,     :null => false
    t.text     "file_ext",                           :default => "",    :null => false
    t.datetime "last_noted_at"
    t.boolean  "is_rating_locked",                   :default => false, :null => false
    t.integer  "parent_id"
    t.boolean  "has_children",                       :default => false, :null => false
    t.integer  "approver_id"
    t.tsvector "tag_index"
    t.integer  "tag_count_general",                  :default => 0,     :null => false
    t.integer  "tag_count_artist",                   :default => 0,     :null => false
    t.integer  "tag_count_character",                :default => 0,     :null => false
    t.integer  "tag_count_copyright",                :default => 0,     :null => false
    t.integer  "file_size"
    t.boolean  "is_status_locked",                   :default => false, :null => false
    t.text     "fav_string",                         :default => "",    :null => false
    t.text     "pool_string",                        :default => "",    :null => false
    t.integer  "up_score",                           :default => 0,     :null => false
    t.integer  "down_score",                         :default => 0,     :null => false
    t.boolean  "is_pending",                         :default => false, :null => false
    t.boolean  "is_flagged",                         :default => false, :null => false
    t.boolean  "is_deleted",                         :default => false, :null => false
    t.integer  "tag_count",                          :default => 0,     :null => false
    t.datetime "updated_at"
  end

  add_index "posts", ["approver_id"], :name => "index_posts_on_approver_id"
  add_index "posts", ["created_at"], :name => "index_posts_on_created_at"
  add_index "posts", ["file_size"], :name => "index_posts_on_file_size"
  add_index "posts", ["image_height"], :name => "index_posts_on_image_height"
  add_index "posts", ["image_width"], :name => "index_posts_on_image_width"
  add_index "posts", ["last_commented_at"], :name => "index_posts_on_last_commented_at"
  add_index "posts", ["last_noted_at"], :name => "index_posts_on_last_noted_at"
  add_index "posts", ["md5"], :name => "index_posts_on_md5", :unique => true
  add_index "posts", ["parent_id"], :name => "index_posts_on_parent_id"
  add_index "posts", ["source"], :name => "index_posts_on_source"
  add_index "posts", ["source"], :name => "index_posts_on_source_pattern"
  add_index "posts", ["tag_index"], :name => "index_posts_on_tag_index"
  add_index "posts", ["uploader_id"], :name => "index_posts_on_uploader_id"
  add_index "posts", ["uploader_ip_addr"], :name => "index_posts_on_uploader_ip_addr"

  create_table "tag_aliases", :force => true do |t|
    t.text     "antecedent_name",                                         :null => false
    t.text     "reason",                         :default => "",          :null => false
    t.integer  "creator_id"
    t.string   "consequent_name",                :default => "",          :null => false
    t.string   "status",                         :default => "active",    :null => false
    t.integer  "forum_topic_id"
    t.string   "creator_ip_addr", :limit => nil, :default => "127.0.0.1", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tag_aliases", ["antecedent_name"], :name => "index_tag_aliases_on_antecedent_name", :unique => true
  add_index "tag_aliases", ["consequent_name"], :name => "index_tag_aliases_on_consequent_name"

  create_table "tag_implications", :force => true do |t|
    t.text     "reason",                          :default => "",          :null => false
    t.integer  "creator_id"
    t.string   "antecedent_name",                 :default => "",          :null => false
    t.string   "consequent_name",                 :default => "",          :null => false
    t.text     "descendant_names",                :default => "",          :null => false
    t.string   "creator_ip_addr",  :limit => nil, :default => "127.0.0.1", :null => false
    t.string   "status",                          :default => "active",    :null => false
    t.integer  "forum_topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tag_subscriptions", :force => true do |t|
    t.integer  "creator_id",                              :null => false
    t.text     "tag_query",                               :null => false
    t.text     "post_ids",         :default => "",        :null => false
    t.string   "name",             :default => "General", :null => false
    t.boolean  "is_public",        :default => true,      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_accessed_at"
    t.boolean  "is_opted_in",      :default => false,     :null => false
  end

  add_index "tag_subscriptions", ["creator_id"], :name => "index_tag_subscriptions_on_creator_id"
  add_index "tag_subscriptions", ["name"], :name => "index_tag_subscriptions_on_name"

  create_table "tags", :force => true do |t|
    t.text     "name",                                                :null => false
    t.integer  "post_count",                           :default => 0, :null => false
    t.text     "related_tags"
    t.datetime "related_tags_updated_at"
    t.integer  "category",                :limit => 2, :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true
  add_index "tags", ["name"], :name => "index_tags_on_name_pattern"
  add_index "tags", ["post_count"], :name => "index_tags_on_post_count"

  create_table "uploads", :force => true do |t|
    t.string   "source"
    t.string   "file_path"
    t.string   "content_type"
    t.string   "rating",           :limit => 1,                          :null => false
    t.integer  "uploader_id",                                            :null => false
    t.string   "uploader_ip_addr", :limit => nil,                        :null => false
    t.text     "tag_string",                                             :null => false
    t.text     "status",                          :default => "pending", :null => false
    t.text     "backtrace"
    t.integer  "post_id"
    t.string   "md5_confirmation"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "uploads", ["uploader_id"], :name => "index_uploads_on_uploader_id"
  add_index "uploads", ["uploader_ip_addr"], :name => "index_uploads_on_uploader_ip_addr"

  create_table "user_feedback", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.integer  "creator_id",                 :null => false
    t.datetime "created_at",                 :null => false
    t.text     "body",                       :null => false
    t.string   "category",   :default => "", :null => false
    t.datetime "updated_at"
  end

  add_index "user_feedback", ["user_id"], :name => "index_user_feedback_on_user_id"

  create_table "user_password_reset_nonces", :force => true do |t|
    t.string   "key",        :null => false
    t.string   "email",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.text     "name",                                                                  :null => false
    t.text     "password_hash",                                                         :null => false
    t.integer  "level",                       :default => 0,                            :null => false
    t.text     "email",                       :default => "",                           :null => false
    t.text     "recent_tags",                 :default => "",                           :null => false
    t.boolean  "always_resize_images",        :default => false,                        :null => false
    t.integer  "inviter_id"
    t.datetime "created_at",                                                            :null => false
    t.datetime "last_logged_in_at"
    t.datetime "last_forum_read_at",          :default => '1960-01-01 00:00:00'
    t.boolean  "has_mail",                    :default => false,                        :null => false
    t.boolean  "receive_email_notifications", :default => false,                        :null => false
    t.integer  "base_upload_limit"
    t.integer  "comment_threshold",           :default => 0,                            :null => false
    t.datetime "updated_at"
    t.string   "email_verification_key"
    t.boolean  "is_banned",                   :default => false,                        :null => false
    t.string   "default_image_size",          :default => "large",                      :null => false
    t.text     "favorite_tags"
    t.text     "blacklisted_tags"
    t.string   "time_zone",                   :default => "Eastern Time (US & Canada)", :null => false
    t.integer  "post_update_count",           :default => 0,                            :null => false
    t.integer  "note_update_count",           :default => 0,                            :null => false
    t.integer  "favorite_count",              :default => 0,                            :null => false
    t.integer  "post_upload_count",           :default => 0,                            :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["inviter_id"], :name => "index_users_on_inviter_id"

  create_table "wiki_page_versions", :force => true do |t|
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.text     "title",                                             :null => false
    t.text     "body",                                              :null => false
    t.integer  "updater_id"
    t.string   "updater_ip_addr", :limit => nil,                    :null => false
    t.integer  "wiki_page_id",                                      :null => false
    t.boolean  "is_locked",                      :default => false, :null => false
  end

  add_index "wiki_page_versions", ["updater_id"], :name => "index_wiki_page_versions_on_updater_id"
  add_index "wiki_page_versions", ["wiki_page_id"], :name => "index_wiki_page_versions_on_wiki_page_id"

  create_table "wiki_pages", :force => true do |t|
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.text     "title",                         :null => false
    t.text     "body",                          :null => false
    t.integer  "creator_id"
    t.boolean  "is_locked",  :default => false, :null => false
    t.tsvector "body_index"
  end

  add_index "wiki_pages", ["body_index"], :name => "index_wiki_pages_on_body_index"
  add_index "wiki_pages", ["title"], :name => "index_wiki_pages_on_title", :unique => true
  add_index "wiki_pages", ["title"], :name => "index_wiki_pages_on_title_pattern"
  add_index "wiki_pages", ["updated_at"], :name => "index_wiki_pages_on_updated_at"

end
