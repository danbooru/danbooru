# frozen_string_literal: true

# A component that renders site announcements at the top of the page.
class NewsUpdateComponent < ApplicationComponent
  attr_reader :cookies

  delegate :close_icon, to: :helpers

  def initialize(cookies:)
    super
    @cookies = cookies
  end

  def render?
    news_update.present? && cookies["news-ticker"].to_i != news_update.id
  end

  def news_update
    NewsUpdate.active.order(created_at: :desc).first
  end
end
