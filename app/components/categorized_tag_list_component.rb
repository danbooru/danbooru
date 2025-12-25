# frozen_string_literal: true

# A vertical tag list, with tags split into categories. Used in app/views/posts/show.html.erb.
class CategorizedTagListComponent < TagListComponent
  NESTABLE_TAG_CATEGORIES = %w[copyright character meta]

  def implications
    @implications ||= TagImplication.active.where(antecedent_name: tags.map(&:name))
  end

  def antecedent_names
    @antecedent_names ||= implications.map(&:antecedent_name)
  end

  def consequent_names
    @consequent_names ||= implications.map(&:consequent_name)
  end

  # Given a list of tags, build a list of nested tags, with the tags nested according to their implication hierarchy.
  #
  # @return An array of tag trees. Each tag tree is an array, where the first element is the parent tag, and the second
  #   element is an optional tree of subtags. An empty array denotes an empty subtree.
  def tag_tree(tag_list = tags, level = 0)
    tag_list.map do |tag|
      # If we're at the top level and this is a subtag (a tag that implies another tag), then ignore it (it will be included beneath another tag)
      if level == 0 && tag.name.in?(antecedent_names)
        nil

      # If this is a parent tag (a tag implied by other tags), then build the subtree of tags that imply it.
      elsif tag.name.in?(consequent_names)
        antecedents = implications.select { |ti| ti.consequent_name == tag.name }.map(&:antecedent_name)
        subtags = tags.select { |t| t.name.in?(antecedents) }

        [tag, tag_tree(subtags, level + 1)]

      # If this tag isn't implied by anything, then it doesn't have any subtags.
      else
        [tag, []]
      end
    end.compact
  end
end
