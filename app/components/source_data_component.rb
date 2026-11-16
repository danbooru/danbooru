# frozen_string_literal: true

class SourceDataComponent < ApplicationComponent
  attr_reader :source

  delegate :spinner_icon, :external_site_icon, to: :helpers

  def initialize(source:)
    super
    @source = source
  end

  # Preload each artist's URLs and tag to avoid N+1 queries. Some extractors return an Array instead of a Relation, so we
  # can't call `includes` here.
  def artists
    @artists ||= source.artists.to_a.tap { ActiveRecord::Associations::Preloader.new(records: it, associations: [:urls, :tag]).call }
  end

  def profile_urls(artist)
    artist.sorted_urls.select(&:is_active?).reject(&:secondary_url?)
  end
end
