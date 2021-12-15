# frozen_string_literal: true

module Normalizable
  extend ActiveSupport::Concern

  class_methods do
    def normalize(attribute, method_name)
      mod = Module.new do
        define_method("#{attribute}=") do |value|
          normalized_value = self.class.send(method_name, value)
          super(normalized_value)
        end
      end

      prepend mod
    end

    private

    def normalize_text(text)
      text.unicode_normalize(:nfc).normalize_whitespace.strip
    end
  end
end
