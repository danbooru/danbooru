class DropTsvectorColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :comments, :body_index, :tsvector
    remove_column :dmails, :message_index, :tsvector
    remove_column :forum_posts, :text_index, :tsvector
    remove_column :forum_topics, :text_index, :tsvector
    remove_column :notes, :body_index, :tsvector
    remove_column :wiki_pages, :body_index, :tsvector
  end
end
