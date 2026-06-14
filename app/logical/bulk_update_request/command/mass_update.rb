# frozen_string_literal: true

# Applies a tag edit to all posts matching a search query.
# The left-hand side is a post search and the right-hand side is a string that will be added to that post's tag string.
class BulkUpdateRequest::Command::MassUpdate < BulkUpdateRequest::Command
  def self.regex
    /\A(?:mass update|update) (?<first_search>.+?) -> (?<second_search>.*)\z/i
  end

  def initialize(params)
    super
    @first_search = params[:first_search]
    @second_search = params[:second_search]
  end

  def from_query
    PostQuery.new(@first_search)
  end

  def to_query
    PostQuery.new(@second_search)
  end

  def affected_tags
    from_query.tag_names + to_query.tag_names
  end

  def process!(**)
    self.class.mass_update(@first_search, @second_search)
  end

  def to_dtext
    lhs = PostQuery.normalize(@first_search, apply_aliases: false)
    rhs = PostQuery.normalize(@second_search, apply_aliases: false)

    lhs_link = lhs.is_simple_tag? ? "[[#{@first_search}]]" : "{{#{@first_search}}}"
    rhs_link = rhs.is_simple_tag? ? "[[#{@second_search}]]" : "{{#{@second_search}}}"

    "mass update #{lhs_link} -> #{rhs_link}"
  end

  def validate(errors:, **)
    if from_query.is_null_search?
      errors.add(:base, "Can't mass update {{#{@first_search}}} -> {{#{@second_search}}} (the search {{#{@first_search}}} has a syntax error)")
    end
  end

  def self.mass_update(antecedent, consequent, user: User.system)
    CurrentUser.scoped(user) do
      Post.anon_tag_match(antecedent).reorder(nil).parallel_find_each do |post|
        post.with_lock do
          post.tag_string += " #{consequent}"
          post.save
        end
      end
    end
  end
end
