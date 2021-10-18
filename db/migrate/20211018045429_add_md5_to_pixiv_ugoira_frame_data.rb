class AddMd5ToPixivUgoiraFrameData < ActiveRecord::Migration[6.1]
  def change
    add_column :pixiv_ugoira_frame_data, :md5, :string, null: true, default: nil
    add_index :pixiv_ugoira_frame_data, :md5, unique: true

    up_only do
      execute "UPDATE pixiv_ugoira_frame_data u SET md5 = p.md5 FROM posts p WHERE p.id = u.post_id"
    end
  end
end
