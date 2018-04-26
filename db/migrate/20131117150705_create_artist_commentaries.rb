class CreateArtistCommentaries < ActiveRecord::Migration[4.2]
  def self.up
    create_table :artist_commentaries do |t|
      t.integer :post_id, :null => false
      t.text :original_title
      t.text :original_description
      t.text :translated_title
      t.text :translated_description

      t.timestamps
    end

    add_index :artist_commentaries, :post_id, :unique => true
  end

  def self.down
    drop_table :artist_commentaries
  end
end
