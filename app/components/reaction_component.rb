# frozen_string_literal: true

class ReactionComponent < ApplicationComponent
  extend Memoist

  MAX_REACTIONS = 10

  attr_reader :model, :current_user
  delegate :add_reaction_icon, to: :helpers

  def initialize(model:, current_user:)
    @model = model
    @current_user = current_user
  end

  memoize def distinct_reactions
    model.reactions.select { |reaction| reaction.reaction_id.in?(Reaction::REACTION_IDS) }.group_by(&:reaction_id)
  end

  def reaction_by_current_user(reaction_id)
    reactions_by_current_user.find { |reaction| reaction.reaction_id == reaction_id }
  end

  memoize def reactions_by_current_user
    model.reactions.select { |reaction| reaction.creator_id == current_user.id }
  end

  def reaction_icon(reaction_id)
    reaction = Reaction::REACTIONS[reaction_id]
    image_tag(reaction[1], class: "h-6", title: ":#{reaction[0]}:")
  end
end
