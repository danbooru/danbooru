class TagPruner
  def prune!
    Tag.without_timeout do
      Tag.destroy_all(["post_count <= 0 and name like '%%:%%'"])
    end
  end
end
