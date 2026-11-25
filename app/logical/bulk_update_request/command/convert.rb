# frozen_string_literal: true

# Converts a pool or favorite group to a tag.
class BulkUpdateRequest::Command::Convert < BulkUpdateRequest::Command
  def self.regex
    /\Aconvert (?<antecedent>.+?) -> (?<consequent>.*)\z/i
  end

  def initialize(params)
    @antecedent = params[:antecedent]
    @consequent = params[:consequent]
    @consequent = Tag.normalize_name(@consequent) if category_term.nil? && PostQuery.normalize(@consequent, apply_aliases: false).is_simple_tag?
  end

  def affected_tags
    to_query.tag_names
  end

  def from_query
    @from_query ||= PostQuery.normalize(@antecedent)
  end

  def tag_edit
    @tag_edit ||= PostEdit.new(nil, "", "", @consequent)
  end

  def category_term
    tag_edit.single_categorization_term
  end

  def tag_name
    category_term&.value || @consequent
  end

  def to_query
    @to_query ||= PostQuery.normalize(tag_name)
  end

  def searched_pools
    from_query.is_single_pool? ? [pool].compact : []
  end

  # Converting a pool deletes it, after its posts are updated.
  def edited_pools
    searched_pools
  end

  def approval_level(tags: nil)
    return User::Levels::ADMIN unless from_query.is_single_favgroup?

    if category_term.present?
      tag = tags.present? ? tags.find { |tag| tag.name == tag_name } : to_query.tag
      return User::Levels::ADMIN if tag.present? && !tag.is_small_tag? && tag.category != category_term.category
    end

    User::Levels::MODERATOR
  end

  def process!(approved_at: nil, **)
    if from_query.is_single_pool?
      convert_pool_to_tag(approved_at: approved_at)
    elsif from_query.is_single_favgroup?
      convert_favgroup_to_tag(approved_at: approved_at)
    end
  end

  def to_dtext
    if category_term.present?
      "convert {{#{@antecedent}}} -> [[#{category_term.value}|#{category_term}]]"
    else
      "convert {{#{@antecedent}}} -> [[#{@consequent}]]"
    end
  end

  def validate(context:, errors:, approver: nil, **)
    if !(from_query.is_single_pool? || from_query.is_single_favgroup?)
      errors.add(:base, "Can't convert {{#{@antecedent}}} -> {{#{@consequent}}} (must convert a pool or favgroup to a tag)")
      return
    end

    target_tag = Tag.new(name: tag_name)

    if !to_query.is_simple_tag?
      errors.add(:base, "Can't convert {{#{@antecedent}}} -> {{#{@consequent}}} (must convert a pool or favgroup to a tag)")
    elsif target_tag.invalid?(:name)
      errors.add(:base, "Can't #{to_dtext} (#{target_tag.errors.full_messages.join("; ")})")
    elsif to_query.tag&.is_deprecated?
      errors.add(:base, "Can't #{to_dtext} ([[#{to_query.tag_name}]] is deprecated)")
    elsif context == :request && category_term.present? && to_query.tag&.artist.present? && category_term.category != Tag.categories.artist
      errors.add(:base, "Can't #{to_dtext} ([[#{to_query.tag_name}]] has an artist entry)")
    elsif from_query.is_single_pool? && pool.nil?
      errors.add(:base, "Can't #{to_dtext} ({{#{@antecedent}}} does not exist)")
    elsif from_query.is_single_favgroup?
      favgroup = from_query.favgroup

      if favgroup.nil?
        errors.add(:base, "Can't #{to_dtext} ({{#{@antecedent}}} does not exist)")
      elsif context == :approval && !approver.is_admin? && favgroup.post_count > Tag::SMALL_TAG_THRESHOLD
        # Checked here instead of in `approval_level` to avoid extra queries on BUR listings.
        errors.add(:base, "Can't approve #{to_dtext} ({{#{@antecedent}}} is too large; requires Admin)")
      end
    end

    BulkUpdateRequest::Command::MassUpdate.simulate_category_change(to_query.tag_name, category_term.category) if errors.empty? && category_term.present?
  end

  private

  # Look up the pool by exact name, so wildcards (`pool:cute_*`) and special values (`pool:any`) don't match.
  def pool
    Pool.find_by_name(from_query.find_metatag(:pool).escape_wildcards)
  end

  def convert_pool_to_tag(approved_at: nil)
    pool = self.pool
    raise BulkUpdateRequest::Processor::Error, "Can't #{to_dtext} ({{#{@antecedent}}} does not exist)" if pool.nil?

    apply_tag_update(approved_at: approved_at)

    wiki_page = WikiPage.find_by_title(to_query) || WikiPage.new(title: to_query.tag_name)
    wiki_page.is_deleted = false
    wiki_page.body = pool.description if wiki_page.body.blank?
    wiki_page.save

    pool.update(is_deleted: true, description: "This pool has been moved to [[#{tag_name}]].", post_ids: [])
  end

  def convert_favgroup_to_tag(approved_at: nil)
    raise BulkUpdateRequest::Processor::Error, "Can't #{to_dtext} ({{#{@antecedent}}} does not exist)" if from_query.favgroup.nil?

    apply_tag_update(approved_at: approved_at)
  end

  def apply_tag_update(approved_at: nil)
    BulkUpdateRequest::Command::MassUpdate.mass_update(from_query, to_query, approved_at: approved_at)
    Tag.find_or_create_by_name(to_query.tag_name, category: category_term.name, current_user: User.system, is_bulk_update_request: true) if category_term.present?
  end
end
