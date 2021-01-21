# frozen_string_literal: true

class PopupMenuComponent < ApplicationComponent
  include ViewComponent::SlotableV2
  delegate :ellipsis_icon, to: :helpers

  renders_many :items
end
