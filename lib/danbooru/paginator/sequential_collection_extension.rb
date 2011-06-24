module Danbooru
  module Paginator
    module SequentialCollectionExtension
      attr_accessor :sequential_paginator_mode
      
      def is_first_page?
        size == 0
      end
      
      def is_last_page?
        size == 0
      end
      
      def to_a
        if sequential_paginator_mode == :before
          super
        else
          super.reverse
        end
      end
    end
  end
end
