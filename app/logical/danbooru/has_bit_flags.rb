module Danbooru
  module HasBitFlags
    extend ActiveSupport::Concern

    module ClassMethods
      # NOTE: the ordering of attributes has to be fixed#
      # new attributes should be appended to the end.
      def has_bit_flags(attributes, options = {})
        field = options[:field] || :bit_flags

        attributes.each.with_index do |attribute, i|
          bit_flag = 1 << i

          define_singleton_method("flag_value_for") do |key|
            index = attributes.index(key)
            raise IndexError if index.nil?
            1 << index
          end

          define_method(attribute) do
            send(field) & bit_flag > 0
          end

          define_method("#{attribute}?") do
            send(field) & bit_flag > 0
          end

          define_method("#{attribute}=") do |val|
            if val.to_s =~ /t|1|y/
              send("#{field}=", send(field) | bit_flag)
            else
              send("#{field}=", send(field) & ~bit_flag)
            end
          end
        end
      end
    end
  end
end
