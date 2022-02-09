# frozen_string_literal: true

class SourceDataComponent < ApplicationComponent
  attr_reader :source

  delegate :spinner_icon, :external_site_icon, to: :helpers

  def initialize(source:)
    super
    @source = source
  end

  def profile_urls(artist)
    artist.sorted_urls.select(&:is_active?).reject(&:secondary_url?)
  end
end
