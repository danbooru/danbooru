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
          c = limit(records_per_page + 1)

          if before_id.to_i > 0
            c = c.where("#{table_name}.id < ?", before_id.to_i)
          end

          c = c.reorder("#{table_name}.id desc")
          c = c.extending(SequentialCollectionExtension)
          c.sequential_paginator_mode = :before
          c
        end

        def paginate_sequential_after(after_id)
          c = limit(records_per_page + 1).where("#{table_name}.id > ?", after_id.to_i).reorder("#{table_name}.id asc")
          c = c.extending(SequentialCollectionExtension)
          c.sequential_paginator_mode = :after
          c
        end

        def paginate_numbered(page)
          page = [page.to_i, 1].max

          if page > Danbooru.config.max_numbered_pages
            raise ::Danbooru::Paginator::PaginationError
          end

          extending(NumberedCollectionExtension).limit(records_per_page).offset((page - 1) * records_per_page).tap do |obj|
            if records_per_page > 0
              obj.total_pages = (obj.total_count.to_f / records_per_page).ceil
            else
              obj.total_pages = 1
            end
            obj.current_page = page
          end
        end

        def records_per_page
          option_for(:limit).to_i
        end

        # When paginating large tables, we want to avoid doing an expensive count query
        # when the result won't even be used. So when calling paginate you can pass in
        # an optional :search_count key which points to the search params. If these params
        # exist, then assume we're doing a search and don't override the default count
        # behavior. Otherwise, just return some large number so the paginator skips the
        # count.
        def option_for(key)
          case key
          when :limit
            limit = @paginator_options.try(:[], :limit) || Danbooru.config.posts_per_page
            if limit.to_i > 1_000
              limit = 1_000
            end
            limit

          when :count
            if @paginator_options.has_key?(:search_count) && @paginator_options[:search_count].blank?
              1_000_000
            elsif @paginator_options[:count]
              @paginator_options[:count]
            else
              nil
            end

          end
        end

        # taken from kaminari (https://github.com/amatsuda/kaminari)
        def total_count
          return option_for(:count) if option_for(:count)

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
