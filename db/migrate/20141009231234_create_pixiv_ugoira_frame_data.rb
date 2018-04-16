class CreatePixivUgoiraFrameData < ActiveRecord::Migration[4.2]
  def change
    create_table :pixiv_ugoira_frame_data do |t|
      t.integer :post_id
      t.text :data
      t.string :content_type
      t.timestamps
    end

    add_index :pixiv_ugoira_frame_data, :post_id, :unique => true
  end
end
