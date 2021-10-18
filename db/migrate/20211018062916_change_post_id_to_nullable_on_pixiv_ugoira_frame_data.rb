class ChangePostIdToNullableOnPixivUgoiraFrameData < ActiveRecord::Migration[6.1]
  def change
    change_column_null :pixiv_ugoira_frame_data, :post_id, true
  end
end
