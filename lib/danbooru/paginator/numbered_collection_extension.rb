module Danbooru
  module Paginator
    module NumberedCollectionExtension
      attr_accessor :current_page, :total_pages
      
      def self.extended(obj)
        obj.extend(Danbooru::Paginator::CollectionExtension)
      end
      
      def is_first_page?
        current_page == 1
      end
      
      def is_last_page?
        current_page == total_pages
      end
      
      def is_sequential_paginator?
        false
      end
      
      def is_numbered_paginator?
        true
      end
    end
  end
end
