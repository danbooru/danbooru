# frozen_string_literal: true

# This component is used to render the other names list on wiki pages.
class ExternalTagLinkComponent < ApplicationComponent
  SITE_LIST = Danbooru.config.tag_lookup_sites

  attr_reader :name

  delegate :external_site_icon, to: :helpers

  # @param tag [String] Tag tag tag tag.
  def initialize(name)
    super
    @name = name
  end
end
