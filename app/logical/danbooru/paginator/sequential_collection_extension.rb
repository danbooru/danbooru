module Danbooru
  module Paginator
    module SequentialCollectionExtension
      attr_accessor :sequential_paginator_mode

      def is_first_page?
        if sequential_paginator_mode == :before
          false
        else
          size <= records_per_page
        end
      end

      def is_last_page?
        if sequential_paginator_mode == :after
          false
        else
          size <= records_per_page
        end
      end

      # XXX Hack: in sequential pagination we fetch one more record than we need
      # so that we can tell when we're on the first or last page. Here we override
      # a rails internal method to discard that extra record. See #2044, #3642.
      def records
        if sequential_paginator_mode == :before
          super.first(records_per_page)
        else
          super.first(records_per_page).reverse
        end
      end
    end
  end
end
