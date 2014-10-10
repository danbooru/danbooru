class CreatePixivUgoiraFrameData < ActiveRecord::Migration
  def change
    create_table :pixiv_ugoira_frame_data do |t|
      t.integer :post_id
      t.text :data
      t.timestamps
    end

    add_index :pixiv_ugoira_frame_data, :post_id, :unique => true
  end
end
