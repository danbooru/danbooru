# frozen_string_literal: true

# Converts a pool or favorite group to a tag.
class BulkUpdateRequest::Command::Convert < BulkUpdateRequest::Command
  def self.regex
    /\Aconvert (?<antecedent>.+?) -> (?<consequent>.*)\z/i
  end

  def initialize(params)
    @antecedent = params[:antecedent]
    @consequent = params[:consequent]
    @consequent = Tag.normalize_name(@consequent) if to_query.is_simple_tag?
  end

  def affected_tags
    to_query.tag_names
  end

  def from_query
    @from_query ||= PostQuery.normalize(@antecedent)
  end

  def to_query
    @to_query ||= PostQuery.normalize(@consequent)
  end

  def approval_level(tags: nil) # rubocop:disable Lint/UnusedMethodArgument
    return User::Levels::MODERATOR if from_query.is_single_favgroup?
    User::Levels::ADMIN
  end

  def process!(**)
    if from_query.is_single_pool?
      convert_pool_to_tag
    elsif from_query.is_single_favgroup?
      BulkUpdateRequest::Command::MassUpdate.mass_update(from_query, to_query)
    end
  end

  def to_dtext
    "convert {{#{@antecedent}}} -> [[#{@consequent}]]"
  end

  def validate(errors:, **)
    prefix, unprefixed_name = @consequent.split(":", 2)

    if !((from_query.is_single_pool? || from_query.is_single_favgroup?) && to_query.is_simple_tag?)
      errors.add(:base, "Can't convert {{#{@antecedent}}} -> {{#{@consequent}}} (must convert a pool or favgroup to a tag)")
    elsif unprefixed_name.present? && TagCategory.mapping.key?(prefix)
      errors.add(:base, "Can't #{to_dtext} (change the category in a separate line)")
    elsif from_query.pool.nil? && from_query.favgroup.nil?
      errors.add(:base, "Can't #{to_dtext} ({{#{@antecedent}}} does not exist)")
    end
  end

  private

  def convert_pool_to_tag
    pool = from_query.pool
    wiki_page = WikiPage.find_by_title(to_query) || WikiPage.new(title: to_query.tag_name)

    wiki_page.is_deleted = false
    wiki_page.body = pool.description if wiki_page.body.blank?
    wiki_page.save

    BulkUpdateRequest::Command::MassUpdate.mass_update(from_query, to_query)

    pool.update(is_deleted: true, description: "This pool has been moved to [[#{@consequent}]].", post_ids: [])
  end
end
