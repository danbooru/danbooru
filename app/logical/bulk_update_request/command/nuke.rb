# frozen_string_literal: true

# Removes a tag or pool from all posts.
class BulkUpdateRequest::Command::Nuke < BulkUpdateRequest::Command
  def self.regex
    /\Anuke (?<tag_or_pool>\S+)\z/i
  end

  def initialize(params)
    super
    @tag_or_pool = params[:tag_or_pool]
  end

  def query
    PostQuery.normalize(@tag_or_pool)
  end

  def affected_pool
    pool_name = query.find_metatag(:pool)
    return nil unless pool_name
    Pool.find_by_name(pool_name)
  end

  def affected_tags
    query.tag_names
  end

  def process!(**)
    if query.is_simple_tag?
      TagImplication.active.where(consequent_name: @tag_or_pool).find_each(&:reject!)
      TagImplication.active.where(antecedent_name: @tag_or_pool).find_each(&:reject!)
    end

    if query.is_metatag?(:pool)
      affected_pool&.update(is_deleted: true, post_ids: [])
    else
      BulkUpdateRequest::Command::MassUpdate.mass_update(@tag_or_pool, "-#{@tag_or_pool}")
    end
  end

  def to_dtext
    if query.is_simple_tag?
      "nuke [[#{@tag_or_pool}]]"
    else
      "nuke {{#{@tag_or_pool}}}"
    end
  end

  def validate(errors:, **)
    if query.is_metatag?(:pool) && affected_pool.nil?
      errors.add(:base, "Can't nuke {{#{query}}} (pool doesn't exist)")
    end
  end
end
