class CreatePostEvents < ActiveRecord::Migration[7.0]
  def change
    create_view :post_events
  end
end
