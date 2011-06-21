module Danbooru
  module Paginator
    module SequentialCollectionExtension
      attr_accessor :sequential_paginator_mode
      
      def self.extended(obj)
        obj.extend(Danbooru::Paginator::CollectionExtension)
      end
      
      def is_first_page?
        size == 0
      end
      
      def is_last_page?
        size == 0
      end
      
      def is_sequential_paginator?
        true
      end
      
      def is_numbered_paginator?
        false
      end
      
      def to_a
        if sequential_paginator_mode == :before
          super
        else
          super.reverse
        end
      end

      def before_id
        if size > 0
          self[-1].id
        else
          nil
        end
      end
      
      def after_id
        if size > 0
          self[0].id
        else
          nil
        end
      end
    end
  end
end
