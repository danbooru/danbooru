# frozen_string_literal: true

class PaginatorJumpComponent < ApplicationComponent
    def initialize(page_count:)
        @page_count = page_count
    end
end
