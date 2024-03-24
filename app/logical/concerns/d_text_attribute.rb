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
    # @param options [Hash] Options to pass to DText.new.
    def dtext_attribute(name, **options)
      mod = Module.new do
        extend Memoist

        define_method "dtext_#{name}" do             # def dtext_body
          DText.new(send(name), **options)           #   DText.new(body, **options)
        end                                          # end

        define_method "dtext_#{name}_was" do         # def dtext_body_was
          DText.new(send("#{name}_was"), **options)  #   DText.new(body_was, **options)
        end                                          # end

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
      end

      prepend mod
    end
  end
end
