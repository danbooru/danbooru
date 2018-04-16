class FixPixivUgoiraFrameData < ActiveRecord::Migration[4.2]
  def change
    change_table :pixiv_ugoira_frame_data do |t|
      t.change :data,         :text,   :null => false
      t.change :content_type, :string, :null => false
      t.remove_timestamps
    end
  end
end
