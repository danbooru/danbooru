require 'active_support/concern'

module Danbooru
  module Paginator
    module ActiveRecordExtension
      extend ActiveSupport::Concern
      
      module ClassMethods
        def paginate(page)
          if use_sequential_paginator?(page)
            paginate_sequential(page)
          else
            paginate_numbered(page)
          end
        end
        
        def use_sequential_paginator?(page)
          page =~ /[ab]\d+/i
        end

        def paginate_sequential(page)
          if page =~ /b(\d+)/
            paginate_sequential_before($1)
          elsif page =~ /a(\d+)/
            paginate_sequential_after($1)
          else
            paginate_numbered(page)
          end
        end

        def paginate_sequential_before(before_id)
          limit(records_per_page).where("id < ?", before_id.to_i).reorder("id desc").tap do |obj|
            obj.extend(SequentialCollectionExtension)
            obj.sequential_paginator_mode = :before
          end
        end

        def paginate_sequential_after(after_id)
          limit(records_per_page).where("id > ?", after_id.to_i).reorder("id asc").tap do |obj|
            obj.extend(SequentialCollectionExtension)
            obj.sequential_paginator_mode = :after
          end
        end
        
        def paginate_numbered(page)
          page = [page.to_i, 1].max
          limit(records_per_page).offset((page - 1) * records_per_page).tap do |obj|
            obj.extend(NumberedCollectionExtension)
            obj.total_pages = (obj.total_count / records_per_page.to_f).ceil
            obj.current_page = page
          end
        end
        
        def records_per_page
          Danbooru.config.posts_per_page
        end

        # taken from kaminari (https://github.com/amatsuda/kaminari)
        def total_count
          c = except(:offset, :limit, :order)
          c = c.reorder(nil)
          c = c.count
          c.respond_to?(:count) ? c.count : c
        end
      end
    end
  end
end
