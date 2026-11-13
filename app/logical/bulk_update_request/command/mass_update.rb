# frozen_string_literal: true

# Applies a tag edit to all posts matching a search query.
# The left-hand side is a post search and the right-hand side is a string that will be added to that post's tag string.
class BulkUpdateRequest::Command::MassUpdate < BulkUpdateRequest::Command
  def self.regex
    /\A(?:mass update|update) (?<first_search>.+?) -> (?<second_search>.*)\z/i
  end

  def initialize(params)
    @first_search = params[:first_search]
    @second_search = params[:second_search]
  end

  def from_query
    PostQuery.new(@first_search)
  end

  def tag_edit
    PostEdit.new(nil, "", "", @second_search)
  end

  def affected_tags
    from_query.tag_names + tag_edit.tag_terms.map(&:name) + tag_edit.tag_categorization_terms.map(&:value)
  end

  def process!(**)
    self.class.mass_update(@first_search, @second_search)
  end

  def to_dtext
    lhs = PostQuery.normalize(@first_search, apply_aliases: false)
    rhs = PostQuery.normalize(@second_search, apply_aliases: false)

    lhs_link = lhs.is_simple_tag? ? "[[#{@first_search}]]" : "{{#{@first_search}}}"
    category_term = tag_edit.tag_categorization_terms.first

    # Link `char:tag` to the tag's wiki, but keep the prefix in the text so it's clear the category is being changed.
    if !rhs.is_simple_tag?
      rhs_link = "{{#{@second_search}}}"
    elsif category_term.present?
      rhs_link = "[[#{category_term.value}|#{@second_search}]]"
    else
      rhs_link = "[[#{@second_search}]]"
    end

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
