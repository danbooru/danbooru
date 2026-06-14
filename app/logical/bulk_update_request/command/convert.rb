# frozen_string_literal: true

# Converts a tag to a pool, or a pool to a tag.
class BulkUpdateRequest::Command::Convert < BulkUpdateRequest::Command
  def self.regex
    /\Aconvert (?<antecedent>.+?) -> (?<consequent>.*)\z/i
  end

  def initialize(params)
    super
    @antecedent = params[:antecedent]
    @consequent = params[:consequent]

    if tag_to_pool?
      @antecedent = Tag.normalize_name(@antecedent)
    elsif pool_to_tag?
      @consequent = Tag.normalize_name(@consequent)
    end
  end

  def affected_tags
    from_query.tag_names + to_query.tag_names
  end

  def from_query
    @from_query ||= PostQuery.normalize(@antecedent)
  end

  def to_query
    @to_query ||= PostQuery.normalize(@consequent)
  end

  def tag_to_pool?
    from_query.is_simple_tag? && to_query.is_single_pool?
  end

  def pool_to_tag?
    from_query.is_single_pool? && to_query.is_simple_tag?
  end

  def process!(**)
    if tag_to_pool?
      convert_tag_to_pool
    elsif pool_to_tag?
      convert_pool_to_tag
    end
  end

  def to_dtext
    if tag_to_pool?
      "convert [[#{@antecedent}]] -> {{#{@consequent}}}"
    elsif pool_to_tag?
      "convert {{#{@antecedent}}} -> [[#{@consequent}]]"
    end
  end

  def validate(errors:, **)
    if tag_to_pool?
      if from_query.tag.nil?
        errors.add(:base, "Can't convert [[#{@antecedent}]] -> {{#{@consequent}}} (tag [[#{@antecedent}]] doesn't exist)")
      elsif from_query.tag&.wiki_page&.body.blank? && to_query.pool&.description.blank?
        errors.add(:base, "Can't convert [[#{@antecedent}]] -> {{#{@consequent}}} (either the tag or the pool must have a description)")
      end
    elsif pool_to_tag?
      if from_query.pool.nil?
        errors.add(:base, "Can't convert {{#{@antecedent}}} -> [[#{@consequent}]] ({{#{@antecedent}}} does not exist)")
      end
    else
      errors.add(:base, "Can't convert {{#{@antecedent}}} -> {{#{@consequent}}} (convert takes exactly one pool and one tag)")
    end
  end

  private

  def convert_tag_to_pool
    pool = to_query.pool || Pool.new(name: to_query.find_metatag(:pool))
    pool.is_deleted = false

    wiki_page = WikiPage.find_by_title(from_query) || WikiPage.new(title: from_query.tag_name)

    pool.description = wiki_page.body if pool.description.blank? && wiki_page.body.present?
    pool.save

    wiki_page.body = "This tag has been moved to {{pool:#{pool.name}}}."
    wiki_page.save

    # at the end so that the pool can be created first
    BulkUpdateRequest::Command::MassUpdate.mass_update(@antecedent, "#{@consequent} -#{@antecedent}")
  end

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
