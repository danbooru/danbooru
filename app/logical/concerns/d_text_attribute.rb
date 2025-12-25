# frozen_string_literal: true

# Declare an attribute as being a DText attribute.
#
#     class Comment < ApplicationRecord
#       # This defines a `dtext_body` method that returns a DText object.
#       dtext_attribute :body
#     end
#
module DTextAttribute
  extend ActiveSupport::Concern

  included do
    extend Memoist
  end

  class_methods do
    # Declare an attribute as being a DText attribute.
    #
    # @param name [Symbol] The name of the attribute to define as a DText attribute.
    # @param media_embeds [Hash] Options for MediaEmbedValidator, including `max_embeds`, `max_large_emojis`,
    #   `max_small_emojis`, `max_video_size`, and `sfw_only`. If blank, media embeds will be disabled.
    # @param options [Hash] Options to pass to DText.new.
    def dtext_attribute(name, media_embeds: {}, **options)
      mod = Module.new do
        extend Memoist
        extend ActiveSupport::Concern

        dtext_options = { media_embeds: media_embeds.present?, **options }

        # def dtext_body
        #   DText.new(body, **dtext_options)
        # end
        define_method "dtext_#{name}" do
          DText.new(send(name), **dtext_options)
        end

        # def dtext_body_was
        #   DText.new(body_was, **dtext_options)
        # end
        define_method "dtext_#{name}_was" do
          DText.new(send("#{name}_was"), **dtext_options)
        end

        define_method "#{name}=" do |value|          # def body=(value)
          super(value)                               #   super(value)
          flush_cache("dtext_#{name}")               #   flush_cache("dtext_body")
          flush_cache("dtext_#{name}_was")           #   flush_cache("dtext_body_was")
        end                                          # end

        define_method "reload" do |**options|
          flush_cache
          super(**options)
        end

        memoize "dtext_#{name}"                      # memoize :dtext_body
        memoize "dtext_#{name}_was"                  # memoize :dtext_body_was

        prepended do
          if media_embeds.present? && method_defined?(:"#{name}_changed?")
            # validates :body, media_embed: { ... }, if: :body_changed?
            validates name, media_embed: media_embeds, if: :"#{name}_changed?"
          elsif media_embeds.present?
            # validates :body, media_embed: { ... }, if: ->(model) { model.dtext_body.present? }
            validates name, media_embed: media_embeds, if: ->(model) { model.send("dtext_#{name}").present? }
          end
        end
      end

      prepend mod
    end
  end
end
