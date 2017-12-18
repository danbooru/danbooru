module Danbooru
  module Paginator
    module NumberedCollectionExtension
      attr_accessor :current_page, :total_pages

      def is_first_page?
        current_page == 1
      end

      def is_last_page?
        current_page >= total_pages
      end
    end
  end
end
