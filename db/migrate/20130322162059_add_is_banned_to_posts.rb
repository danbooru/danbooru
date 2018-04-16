class AddIsBannedToPosts < ActiveRecord::Migration[4.2]
  def up
    execute("set statement_timeout = 0")
    add_column :posts, :is_banned, :boolean, :null => false, :default => false
    Artist.banned.each do |artist|
      Post.raw_tag_match(artist.name).each do |post|
        post.update_column(:is_banned, true)
      end
    end
    PostFlag.where("reason ilike '%requested%' and reason <> 'Artist requested removal'").each do |flag|
      flag.post.update_column(:is_banned, true)
    end

    PostFlag.where("reason ilike '%banned artist%'").each do |flag|
      flag.post.update_column(:is_banned, true)
    end
  end
end
