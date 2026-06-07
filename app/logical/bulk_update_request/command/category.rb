# frozen_string_literal: true

# Changes a tag's category.
# The tag must already exist and must not have an artist entry if switching away from the artist category.
class BulkUpdateRequest::Command::Category < BulkUpdateRequest::Command
  def self.regex
    /\Acategory (?<tag_name>\S+) -> (?<category_name>.*)\z/i
  end

  def initialize(params)
    super
    @tag_name = Tag.normalize_name(params[:tag_name])
    @category_name = params[:category_name].downcase
  end

  def affected_tags
    [@tag_name]
  end

  def process!(**)
    tag ||= Tag.new(@tag_name)
    tag.update!(category: category, updater: User.system, is_bulk_update_request: true)
  end

  def to_dtext
    "category [[#{@tag_name}]] -> #{@category_name}"
  end

  def validate(context:, errors:)
    if tag.nil?
      errors.add(:base, "Can't change the category of [[#{@tag_name}]] to #{@category_name} ([[#{@tag_name}]] doesn't exist)")
    elsif category.nil?
      errors.add(:base, "Can't change the category of [[#{@tag_name}]] to #{@category_name} (#{@category_name} is not a valid category)")
    elsif context == :approval
      # do nothing
    elsif category == tag.category
      errors.add(:base, "Can't change the category of [[#{@tag_name}]] to #{@category_name} ([[#{@tag_name}]] is already in that category)")
    elsif tag.artist.present? && category != Tag.categories.artist
      errors.add(:base, "Can't change the category of [[#{@tag_name}]] to #{@category_name} ([[#{@tag_name}]] has an artist entry)")
    end
  end

  def tag
    @tag ||= Tag.find_by_name(@tag_name)
  end

  def category
    Tag.categories.value_for(@category_name)
  end
end
