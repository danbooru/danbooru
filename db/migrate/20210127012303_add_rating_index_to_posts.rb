class AddRatingIndexToPosts < ActiveRecord::Migration[6.1]
  def change
    add_index :posts, :rating, where: "rating != 's'"
  end
end
