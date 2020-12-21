module Normalizable
  extend ActiveSupport::Concern

  class_methods do
    def normalize(attribute, method_name)
      define_method("#{attribute}=") do |value|
        normalized_value = self.class.send(method_name, value)
        super(normalized_value)
      end
    end

    private

    def normalize_text(text)
      text.unicode_normalize(:nfc).normalize_whitespace.strip
    end
  end
end
