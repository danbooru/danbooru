module PoolVersionsHelper
  def pool_version_diff(current)
    prev = PoolVersion.where(["pool_id = ? and id < ?", current.pool_id, current.id]).order("id desc").first

    if prev.nil?
      return current.post_id_array.map {|x| content_tag("ins", "+#{x}")}.join(" ").html_safe
    end

    added = current.post_id_array - prev.post_id_array
    removed = prev.post_id_array - current.post_id_array

    (added.map {|x| '<ins>+<a href="/posts/' + x.to_s + '">' + x.to_s + '</a></ins>'}.join(" ") + removed.map {|x| '<del>&ndash;<a href="/posts/' + x.to_s + '">' + x.to_s + '</a></del>'}.join(" ")).html_safe
  end
end
