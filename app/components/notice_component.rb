# frozen_string_literal: true

# This component is used to render notices, which are short temporary messages displayed at the top of the page. This
# is also known as a "toast" or "snack bar" in other component systems.
#
# Danbooru has a single global notice that can be triggered by Javascript with `Danbooru.Notice.info("message")`.
class NoticeComponent < ApplicationComponent
  # @param dtext [String] The DText-formatted message to display in the notice.
  def initialize(dtext)
    super
    @dtext = dtext
  end

  # @return [String, nil] The HTML-formatted message to display in the notice, or nil if no message is set.
  def message
    @message ||= format_text(@dtext, inline: true) if @dtext.present?
  end
end
