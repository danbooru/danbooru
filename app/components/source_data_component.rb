# frozen_string_literal: true

class SourceDataComponent < ApplicationComponent
  attr_reader :source
  delegate :spinner_icon, :external_site_icon, to: :helpers

  def initialize(source:)
    @source = source
  end

  def profile_urls(artist)
    artist.urls.active.reject(&:secondary_url?).sort_by do |artist_url|
      [artist_url.priority, artist_url.domain, artist_url.url]
    end
  end
end
