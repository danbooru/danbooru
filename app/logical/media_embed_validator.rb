# frozen_string_literal: true

# A custom validator that validates which media embeds are allowed in DText attributes.
#
# @example
#   validates :body, media_embed: true
#
# @see https://guides.rubyonrails.org/active_record_validations.html#custom-validators
class MediaEmbedValidator < ActiveModel::EachValidator
  attr_reader :max_embeds, :max_video_size, :max_large_emojis, :max_small_emojis, :sfw_only

  def initialize(options)
    super
    @max_embeds = options[:max_embeds]
    @max_video_size = options[:max_video_size]
    @max_large_emojis = options[:max_large_emojis]
    @max_small_emojis = options[:max_small_emojis]
    @sfw_only = options[:sfw_only]
  end

  # @param model [ApplicationRecord] The comment, forum post, or other model being validated.
  # @param attribute [Symbol] The name of the attribute being validated (e.g., :body).
  # @param _value [String] The value of the attribute being validated.
  def validate_each(model, attribute, _value)
    dtext = model.send("dtext_#{attribute}")

    if max_large_emojis.present? && dtext.block_emoji_names.count > max_large_emojis
      model.errors.add(attribute, "can't include more than #{max_large_emojis} #{"sticker".pluralize(max_large_emojis)}")
    end

    if max_small_emojis.present? && dtext.inline_emoji_names.count > max_small_emojis
      model.errors.add(attribute, "can't include more than #{max_small_emojis} #{"emoji".pluralize(max_small_emojis)}")
    end

    if max_embeds.present? && dtext.embedded_media.count > max_embeds
      model.errors.add(attribute, "can't include more than #{max_embeds} #{"image".pluralize(max_embeds)}")
      return # don't check the actual images if the user included too many images
    end

    if max_video_size.present? && dtext.embedded_posts.any? { |post| post.is_video? && post.file_size > max_video_size }
      model.errors.add(attribute, "can't include videos larger than #{max_video_size.to_fs(:human_size)}")
    end

    if max_video_size.present? && dtext.embedded_media_assets.any? { |asset| asset.is_video? && asset.file_size > max_video_size }
      model.errors.add(attribute, "can't include videos larger than #{max_video_size.to_fs(:human_size)}")
    end

    if sfw_only && dtext.embedded_posts.any?(&:is_nsfw?)
      model.errors.add(attribute, "can't include NSFW images")
    end

    if sfw_only && dtext.embedded_media_assets.any?(&:is_ai_nsfw?)
      model.errors.add(attribute, "can't include NSFW images")
    end
  end
end
