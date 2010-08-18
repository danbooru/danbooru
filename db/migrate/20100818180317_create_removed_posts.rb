class CreateRemovedPosts < ActiveRecord::Migration
  def self.up
    create_table :removed_posts do |t|
      t.timestamps
      
      t.column :score, :integer, :null => false, :default => 0
      t.column :source, :string
      t.column :md5, :string, :null => false
      t.column :rating, :character, :null => false, :default => 'q'

      # Statuses
      t.column :is_note_locked, :boolean, :null => false, :default => false
      t.column :is_rating_locked, :boolean, :null => false, :default => false
      t.column :is_pending, :boolean, :null => false, :default => false
      t.column :is_flagged, :boolean, :null => false, :default => false

      # Uploader
      t.column :uploader_string, :string, :null => false
      t.column :uploader_ip_addr, "inet", :null => false
      
      # Approver
      t.column :approver_string, :string, :null => false, :default => ""

      # Favorites
      t.column :fav_string, :text, :null => false, :default => ""

      # Pools
      t.column :pool_string, :text, :null => false, :default => ""

      # Cached
      t.column :view_count, :integer, :null => false, :default => 0
      t.column :last_noted_at, :datetime
      t.column :last_commented_at, :datetime

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
    
    add_index :removed_posts, :md5, :unique => true
    add_index :removed_posts, :created_at
    add_index :removed_posts, :last_commented_at
    add_index :removed_posts, :last_noted_at
    add_index :removed_posts, :file_size
    add_index :removed_posts, :image_width
    add_index :removed_posts, :image_height
    add_index :removed_posts, :source
    add_index :removed_posts, :view_count
    add_index :removed_posts, :parent_id
    
    execute "CREATE INDEX index_removed_posts_on_mpixels ON posts (((image_width * image_height)::numeric / 1000000.0))"

    execute "CREATE INDEX index_removed_posts_on_tags_index ON posts USING gin (tag_index)"
    execute "CREATE TRIGGER trigger_removed_posts_on_tag_index_update BEFORE INSERT OR UPDATE ON removed_posts FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tag_index', 'public.danbooru', 'tag_string', 'fav_string', 'pool_string', 'uploader_string', 'approver_string')"
  end

  def self.down
    drop_table :removed_posts
  end
end
