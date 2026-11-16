# frozen_string_literal: true

# Helpers for the English / Simplified Chinese language switcher.
module LocaleHelper
  LOCALE_OPTIONS = [
    { code: "en", label: "English" },
    { code: "zh-CN", label: "简体中文" },
  ].freeze

  # Builds a link to the current page with only the `locale` query parameter
  # changed. Keeping the rest of the query string means switching language
  # doesn't drop tags, page numbers, or search filters.
  #
  # current_page_path goes through ApplicationHelper#url_for, which strips
  # reserved url_for options (protocol, host, port, script_name) from the
  # request params. Building the URL by hand from request.fullpath would let
  # `/tags?protocol=javascript&host=...` be reflected into the href, turning
  # the switcher link into a `javascript:` URL.
  def locale_switch_url(locale)
    current_page_path(locale: locale)
  end

  # Renders "English / 简体中文" with the active language highlighted.
  def locale_switcher_links
    links = LOCALE_OPTIONS.map do |option|
      code = option[:code]
      active = I18n.locale.to_s == code
      link_to option[:label], locale_switch_url(code),
              class: (active ? "current font-bold locale-active" : "locale-inactive"),
              lang: code, hreflang: code, rel: "nofollow",
              title: t("locale_switcher.title"), "aria-current": (active ? "true" : nil)
    end

    links.join(" / ").html_safe
  end
end
