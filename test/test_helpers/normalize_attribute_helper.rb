# A custom Shoulda matcher for testing that a model correctly normalizes an attribute.
#
# Usage:
#
#   subject { build(:wiki_page) }
#   should normalize_attribute(:title).from(" Azur  Lane ").to("azur_lane")
#
# https://thoughtbot.com/blog/shoulda-matchers

module NormalizeAttributeHelper
  def normalize_attribute(attribute)
    NormalizeAttributeMatcher.new(attribute)
  end

  class NormalizeAttributeMatcher
    attr_reader :attribute, :from_value, :to_value

    def initialize(attribute)
      @attribute = attribute
    end

    def matches?(subject)
      subject.send("#{attribute}=", from_value)
      subject.send(attribute) == to_value
    end

    def description
      "normalize the `#{attribute}` attribute from `#{from_value}` to `#{to_value}`"
    end

    def failure_message
      "expected `#{attribute}=` to normalize `#{from_value}` to `#{to_value}`"
    end

    def from(from_value)
      @from_value = from_value
      self
    end

    def to(to_value)
      @to_value = to_value
      self
    end
  end
end
