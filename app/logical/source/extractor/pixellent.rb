# frozen_string_literal: true

# @see Source::URL::Pixellent
class Source::Extractor::Pixellent < Source::Extractor
  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    elsif post[:imageDir].present?
      file = "#{post[:imageDir]}/original"
      ["https://firebasestorage.googleapis.com/v0/b/pixellent.appspot.com/o/#{Danbooru::URL.escape(file)}?alt=media"]
    else
      []
    end
  end

  def profile_url
    username_url || user_id_url
  end

  def profile_urls
    [username_url, user_id_url].compact
  end

  def username_url
    "https://pixellent.me/@#{username}" if username.present?
  end

  def user_id_url
    "https://pixellent.me/@u-#{user_id}" if user_id.present?
  end

  def display_name
    user[:name]
  end

  def username
    user[:userName]
  end

  def user_id
    user[:id]
  end

  def tags
    post[:hashtags].to_a.map do |tag|
      [tag, "https://pixellent.me/tag/#{Danbooru::URL.escape(tag)}"]
    end
  end

  def artist_commentary_title
    post[:title]
  end

  def artist_commentary_desc
    post[:story]
  end

  def html_artist_commentary_desc
    artist_commentary_desc&.normalize_whitespace&.gsub(/[#＃]([^[:space:]]+)/) do |hashtag|
      tag = $1
      %{<a href="https://pixellent.me/tag/#{CGI.escapeHTML(Danbooru::URL.escape(tag))}">##{CGI.escapeHTML(tag)}</a>}
    end&.gsub("\r\n", "<br>")
  end

  def dtext_artist_commentary_desc
    DText.from_html(html_artist_commentary_desc, base_url: "https://pixellent.me")
  end

  memoize def page
    http.cache(1.minute).parsed_get(page_url)
  end

  memoize def page_json
    page&.at("#__NEXT_DATA__")&.text&.parse_json || {}
  end

  memoize def post
    page_json.dig(:props, :pageProps, :post) || {}
  end

  memoize def user
    page_json.dig(:props, :pageProps, :user) || {}
  end
end
