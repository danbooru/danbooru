Rails.application.reloader.to_prepare do
  # This file has to be manually reloaded because the DText class is defined in two places, once in the dtext_rb gem and
  # once in app/logical, and the one in the gem takes precedence over the one in app/logical.
  require_relative "../../app/logical/d_text"
end

DText.add_emoji_list("default", Danbooru.config.dtext_emojis.keys.map(&:downcase))
