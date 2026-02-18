# frozen_string_literal: true

module Danbooru
  module Helpers
    module_function
    extend ActionView::Helpers::DateHelper
    extend ApplicationHelper

    def time_from_ms_since_epoch(milliseconds)
      return unless milliseconds.present?
      seconds, milliseconds = milliseconds.to_i.divmod(1000)
      Time.at(seconds, milliseconds, :millisecond).utc
    end
  end
end
