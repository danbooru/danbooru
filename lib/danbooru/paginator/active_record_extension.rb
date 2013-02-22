require 'active_support/concern'

module Danbooru
  module Paginator
    module ActiveRecordExtension
      extend ActiveSupport::Concern
      
      module ClassMethods
        def paginate(page, options = {})
          @paginator_options = options
          
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
            paginate_sequential_before
          end
        end

        def paginate_sequential_before(before_id = nil)
          c = limit(records_per_page)
          
          if before_id.to_i > 0
            c = c.where("id < ?", before_id.to_i)
          end
          
          c.reorder("id desc").tap do |obj|
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
          
          if page > Danbooru.config.max_numbered_pages
            raise ::Danbooru::Paginator::PaginationError.new("You cannot go beyond page #{Danbooru.config.max_numbered_pages}. Please narrow your search terms.")
          end
          
          limit(records_per_page).offset((page - 1) * records_per_page).tap do |obj|
            obj.extend(NumberedCollectionExtension)
            if records_per_page > 0
              obj.total_pages = (obj.total_count.to_f / records_per_page).ceil
            else
              obj.total_pages = 1
            end
            obj.current_page = page
          end
        end
        
        def records_per_page
          (@paginator_options.try(:[], :limit) || Danbooru.config.posts_per_page).to_i
        end

        # taken from kaminari (https://github.com/amatsuda/kaminari)
        def total_count
          return @paginator_options[:count] if @paginator_options[:count]
          
          c = except(:offset, :limit, :order)
          c = c.reorder(nil)
          c = c.count
          c.respond_to?(:count) ? c.count : c
        rescue ActiveRecord::StatementInvalid => e
          if e.to_s =~ /statement timeout/
            1_000_000
          else
            raise
          end
        end
      end
    end
  end
end
