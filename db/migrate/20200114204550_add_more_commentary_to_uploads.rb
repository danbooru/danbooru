class AddMoreCommentaryToUploads < ActiveRecord::Migration[6.0]
  def change
    add_column :uploads, :translated_commentary_title, :text, null: false, default: ""
    add_column :uploads, :translated_commentary_desc, :text, null: false, default: ""
  end
end
