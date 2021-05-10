class RemoveDefaultsFromUsers < ActiveRecord::Migration[6.1]
  def change
    change_table(:users) do |t|
      t.change_default :level, from: 20, to: nil
      t.change_default :last_logged_in_at, from: "now()", to: nil
      t.change_default :last_forum_read_at, from: "1960-01-01 00:00:00", to: nil
      t.change_default :comment_threshold, from: 0, to: nil
      t.change_default :default_image_size, from: "large", to: nil
      t.change_default :blacklisted_tags, from: "spoilers\nguro\nscat\nfurry -rating:s", to: nil
      t.change_default :time_zone, from: "Eastern Time (US & Canada)", to: nil
      t.change_default :post_update_count, from: 0, to: nil
      t.change_default :note_update_count, from: 0, to: nil
      t.change_default :favorite_count, from: 0, to: nil
      t.change_default :post_upload_count, from: 0, to: nil
      t.change_default :per_page, from: 20, to: nil
      t.change_default :bit_prefs, from: 0, to: nil
      t.change_default :unread_dmail_count, from: 0, to: nil
      t.change_default :theme, from: 0, to: nil
      t.change_default :upload_points, from: 1000, to: nil
    end
  end
end
