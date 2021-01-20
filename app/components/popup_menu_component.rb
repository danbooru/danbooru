# frozen_string_literal: true

class PopupMenuComponent < ApplicationComponent
  include ViewComponent::SlotableV2

  renders_many :items
end
