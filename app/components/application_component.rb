# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  delegate :link_to_user, :time_ago_in_words_tagged, :format_text, :external_link_to, :tag_class, :current_page_path, to: :helpers
  delegate :edit_icon, :delete_icon, :undelete_icon, :flag_icon, :upvote_icon, :downvote_icon, :link_icon, :sticky_icon, :unsticky_icon, :hashtag_icon, :caret_down_icon, :image_icon, :spinner_icon, :help_icon, :ban_icon, to: :helpers

  def initialize(*args, **options)
  end

  def policy(subject)
    Pundit.policy!(current_user, subject)
  end
end
