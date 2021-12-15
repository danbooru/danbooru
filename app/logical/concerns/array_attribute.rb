# frozen_string_literal: true

module ArrayAttribute
  extend ActiveSupport::Concern

  class_methods do
    # Defines `<attribute>_string`, `<attribute>_string=`, and `<attribute>=`
    # methods for converting an array attribute to or from a string.
    #
    # The `<attribute>=` setter parses strings into an array using the
    # `parse` regex. The resulting strings can be converted to another type
    # with the `cast` option.
    def array_attribute(name, parse: /[^[:space:]]+/, cast: :itself)
      mod = Module.new do
        define_method "#{name}_string" do
          send(name).join(" ")
        end

        define_method "#{name}_string=" do |value|
          raise ArgumentError, "#{name} must be a String" unless value.respond_to?(:to_str)
          send("#{name}=", value)
        end

        define_method "#{name}=" do |value|
          if value.respond_to?(:to_str)
            super value.to_str.scan(parse).map(&cast)
          elsif value.respond_to?(:to_a)
            super value.to_a
          else
            raise ArgumentError, "#{name} must be a String or an Array"
          end
        end
      end

      prepend mod
    end
  end
end
