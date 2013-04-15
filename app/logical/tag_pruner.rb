class TagPruner
  def prune!
    Tag.without_timeout do
    end
  end
end
