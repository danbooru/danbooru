class CreatePosts < ActiveRecord::Migration[4.2]
  def self.up
    create_table :posts do |t|
      t.timestamps

      t.column :up_score, :integer, :null => false, :default => 0
      t.column :down_score, :integer, :null => false, :default => 0
      t.column :score, :integer, :null => false, :default => 0
      t.column :source, :string
      t.column :md5, :string, :null => false
      t.column :rating, :character, :null => false, :default => 'q'

      # Statuses
      t.column :is_note_locked, :boolean, :null => false, :default => false
      t.column :is_rating_locked, :boolean, :null => false, :default => false
      t.column :is_status_locked, :boolean, :null => false, :default => false
      t.column :is_pending, :boolean, :null => false, :default => false
      t.column :is_flagged, :boolean, :null => false, :default => false
      t.column :is_deleted, :boolean, :null => false, :default => false

      # Uploader
      t.column :uploader_id, :integer, :null => false
      t.column :uploader_ip_addr, "inet", :null => false

      # Approver
      t.column :approver_id, :integer

      # Favorites
      t.column :fav_string, :text, :null => false, :default => ""

      # Pools
      t.column :pool_string, :text, :null => false, :default => ""

      # Cached
      t.column :last_noted_at, :datetime
      t.column :last_commented_at, :datetime
      t.column :fav_count, :integer, :null => false, :default => 0

      # Tags
      t.column :tag_string, :text, :null => false, :default => ""
      t.column :tag_index, "tsvector"
      t.column :tag_count, :integer, :null => false, :default => 0
      t.column :tag_count_general, :integer, :null => false, :default => 0
      t.column :tag_count_artist, :integer, :null => false, :default => 0
      t.column :tag_count_character, :integer, :null => false, :default => 0
      t.column :tag_count_copyright, :integer, :null => false, :default => 0

      # File
      t.column :file_ext, :string, :null => false
      t.column :file_size, :integer, :null => false
      t.column :image_width, :integer, :null => false
      t.column :image_height, :integer, :null => false

      # Parent
      t.column :parent_id, :integer
      t.column :has_children, :boolean, :null => false, :default => false
    end

    add_index :posts, :md5, :unique => true
    add_index :posts, :created_at
    add_index :posts, :last_commented_at
    add_index :posts, :last_noted_at
    add_index :posts, :file_size
    add_index :posts, :image_width
    add_index :posts, :image_height
    add_index :posts, :source
    add_index :posts, :parent_id
    add_index :posts, :uploader_id
    add_index :posts, :uploader_ip_addr

    execute "create index index_posts_on_source_pattern on posts (source text_pattern_ops)"
    execute "create index index_posts_on_created_at_date on posts (date(created_at))"
    execute "CREATE INDEX index_posts_on_mpixels ON posts (((image_width * image_height)::numeric / 1000000.0))"

    execute "SET statement_timeout = 0"
    execute "SET search_path = public"

    execute "CREATE OR REPLACE FUNCTION testprs_start(internal, int4)
    RETURNS internal
    AS '$libdir/test_parser'
    LANGUAGE C STRICT"

    execute "CREATE OR REPLACE FUNCTION testprs_getlexeme(internal, internal, internal)
    RETURNS internal
    AS '$libdir/test_parser'
    LANGUAGE C STRICT"

    execute "CREATE OR REPLACE FUNCTION testprs_end(internal)
    RETURNS void
    AS '$libdir/test_parser'
    LANGUAGE C STRICT"

    execute "CREATE OR REPLACE FUNCTION testprs_lextype(internal)
    RETURNS internal
    AS '$libdir/test_parser'
    LANGUAGE C STRICT"

    execute "CREATE TEXT SEARCH PARSER testparser (
        START    = testprs_start,
        GETTOKEN = testprs_getlexeme,
        END      = testprs_end,
        HEADLINE = pg_catalog.prsd_headline,
        LEXTYPES = testprs_lextype
    )"

    execute "CREATE INDEX index_posts_on_tags_index ON posts USING gin (tag_index)"
    execute "CREATE TEXT SEARCH CONFIGURATION public.danbooru (PARSER = public.testparser)"
    execute "ALTER TEXT SEARCH CONFIGURATION public.danbooru ADD MAPPING FOR WORD WITH SIMPLE"
    execute "SET default_text_search_config = 'public.danbooru'"
    execute "CREATE TRIGGER trigger_posts_on_tag_index_update BEFORE INSERT OR UPDATE ON posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string')"
  end

  def self.down
    drop_table :posts
  end
end
