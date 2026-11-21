# frozen_string_literal: true

# Applies a tag edit to all posts matching a search query.
# The left-hand side is a post search and the right-hand side is a string that will be added to that post's tag string.
class BulkUpdateRequest::Command::MassUpdate < BulkUpdateRequest::Command
  ALLOWED_METATAGS = %w[parent -parent child -child rating source pool -pool newpool] + TagCategory.categories

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
    @tag_edit ||= PostEdit.new(nil, "", "", @second_search)
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
    if category_term&.value.present? && tag_edit.terms.one?
      rhs_link = "[[#{category_term.value}|#{@second_search}]]"
    elsif rhs.is_simple_tag?
      rhs_link = "[[#{@second_search}]]"
    else
      rhs_link = "{{#{@second_search}}}"
    end

    "mass update #{lhs_link} -> #{rhs_link}"
  end

  def validate(errors:, **)
    if from_query.is_null_search?
      errors.add(:base, "Can't mass update {{#{@first_search}}} -> {{#{@second_search}}} (the search {{#{@first_search}}} has a syntax error)")
    end

    disallowed_metatags.each do |metatag|
      errors.add(:base, "Can't #{to_dtext} ('#{metatag}:' metatag is not allowed)")
    end

    tag_edit.unclosed_metatags.each do |metatag|
      errors.add(:base, "Can't #{to_dtext} ('#{metatag}:' metatag has an unclosed quote)")
    end

    from_query.select_metatags(*PostQuery::ORDER_METATAGS, :limit, :random).map(&:name).uniq.each do |name|
      errors.add(:base, "Can't #{to_dtext} ('#{name}:' metatag is not allowed in the search)")
    end

    # Pools are looked up by exact name, so wildcards (`pool:cute_*`) and special values (`pool:any`) are rejected.
    from_query.select_metatags(:pool).each do |metatag|
      if Pool.find_by_name(metatag.value.escape_wildcards).nil?
        errors.add(:base, "Can't #{to_dtext} ({{#{metatag}}} does not exist)")
      end
    end

    from_query.select_metatags(:favgroup).each do |metatag|
      if FavoriteGroup.visible(User.anonymous).find_by_name_or_id(metatag.value, User.anonymous).nil?
        errors.add(:base, "Can't #{to_dtext} ({{#{metatag}}} does not exist)")
      end
    end

    # Post edits look up pools by wildcard, so `pool:cute_*` would add posts to whichever pool matched first.
    tag_edit.metatag_terms.each do |metatag|
      if metatag.name.in?(%w[pool -pool]) && Pool.find_by_name(metatag.value.escape_wildcards).nil?
        errors.add(:base, "Can't #{to_dtext} ({{#{metatag.name}:#{metatag.value}}} does not exist)")
      elsif metatag.name == "newpool" && metatag.value.include?("*")
        errors.add(:base, "Can't #{to_dtext} (pool names can't contain asterisks)")
      end
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

  private

  def disallowed_metatags
    metatags = tag_edit.metatag_terms.map(&:name).reject { |name| name.in?(ALLOWED_METATAGS) }
    (metatags + tag_edit.invalid_metatags).uniq
  end
end
