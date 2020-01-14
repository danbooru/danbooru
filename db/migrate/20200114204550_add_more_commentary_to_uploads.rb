class AddMoreCommentaryToUploads < ActiveRecord::Migration[6.0]
  def change
    add_column :uploads, :translated_commentary_title, :text
    add_column :uploads, :translated_commentary_desc, :text
    add_column :uploads, :add_commentary_tag, :boolean
    add_column :uploads, :add_commentary_request_tag, :boolean
    add_column :uploads, :add_commentary_check_tag, :boolean
    add_column :uploads, :add_partial_commentary_tag, :boolean
  end
end
