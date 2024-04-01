# frozen_string_literal: true

class EmojiSelectorComponent < ApplicationComponent
  delegate :add_reaction_icon, to: :helpers
end
