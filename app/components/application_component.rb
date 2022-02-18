# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  delegate :link_to_user, :time_ago_in_words_tagged, :format_text, :external_link_to, :tag_class, :current_page_path, to: :helpers
  delegate :edit_icon, :delete_icon, :undelete_icon, :flag_icon, :upvote_icon, :downvote_icon, :link_icon, :sticky_icon, :unsticky_icon, :hashtag_icon, :caret_down_icon, :image_icon, :spinner_icon, to: :helpers

  def policy(subject)
    Pundit.policy!(current_user, subject)
  end

  # XXX Silence warnings about `with_variant` being deprecated until we can fix it.
  # DEPRECATION WARNING: `with_variant` is deprecated and will be removed in ViewComponent v3.0.0
  def with_variant(...)
    ActiveSupport::Deprecation.silence do
      super(...)
    end
  end
end
