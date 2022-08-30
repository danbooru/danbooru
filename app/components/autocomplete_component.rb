# frozen_string_literal: true

class AutocompleteComponent < ApplicationComponent
  attr_reader :autocomplete_service

  delegate :humanized_number, to: :helpers
  delegate :autocomplete_results, to: :autocomplete_service

  def initialize(autocomplete_service:)
    @autocomplete_service = autocomplete_service
  end

  def link_to_result(result, &block)
    case result.type
    when "user"
      link_to user_path(result.id), class: "user-#{result.level}", "@click.prevent": "", &block
    when "pool"
      link_to pool_path(result.id), class: "pool-category-#{result.category}", "@click.prevent": "", &block
    else
      link_to posts_path(tags: result.value), class: "tag-type-#{result.category}", "@click.prevent": "", &block
    end
  end
end
