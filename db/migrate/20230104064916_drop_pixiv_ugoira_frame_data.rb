class DropPixivUgoiraFrameData < ActiveRecord::Migration[7.0]
  def change
    drop_table :pixiv_ugoira_frame_data, id: :integer do |t|
      t.belongs_to :post, foreign_key: { deferrable: true }, index: { unique: true }
      t.text :data, null: false
      t.string :content_type, null: false
      t.string :md5, index: { unique: true }
    end
  end
end
