# frozen_string_literal: true

# Renders the "English / 简体中文" language switcher.
#
# This is a component rather than a plain view partial so it can be rendered
# from the layout, from the navbar component, and from the error page, even
# when the surrounding view context doesn't include every app helper (the
# error page is rendered from a rescue handler).
class LocaleSwitcherComponent < ApplicationComponent
  include LocaleHelper
end
