# frozen_string_literal: true

# @see Source::URL::PixivComic
class Source::Extractor::PixivComic < Source::Extractor
  CLIENT_HASH_SALT = "mAtW1X8SzGS880fsjEXlM73QpS1i4kUMBhyhdaYySk8nWz533nrEunaSplg63fzT"

  def image_urls
    if parsed_url.full_image_url.present?
      [parsed_url.full_image_url]
    elsif parsed_url.image_url?
      [parsed_url.to_s]
    elsif story.present?
      story["pages"].to_a.pluck("url").map do |url|
        Source::URL.parse(url)&.full_image_url || url
      end
    elsif novel_story.present?
      novel_story["pages"].to_a.pluck("url").map do |url|
        Source::URL.parse(url)&.full_image_url || url
      end
    elsif work.present?
      url = work.dig("official_work", "image", "main_big")
      [Source::URL.parse(url).full_image_url].compact
    elsif novel_work.present?
      url = novel_work.dig("official_work", "image", "main_big")
      [Source::URL.parse(url).full_image_url].compact
    elsif magazine.present?
      url = magazine.dig("magazine", "image", "main")
      [Source::URL.parse(url).full_image_url].compact
    else
      []
    end
  end

  def artist_name
    if work.present?
      work.dig("official_work", "author")
    elsif novel_work.present?
      # Novels have both an author and an illustrator; use only the illustrator as the artist name.
      # 著者：江ノ島アビス\r\nイラスト：植田 亮 => Author: Enoshima Abyss\r\nIllustration: Ryo Ueda
      novel_work.dig("official_work", "author")&.slice(/イラスト：(.*)/, 1)
    end
  end

  def tags
    tags = work.dig("official_work", "categories").to_a.pluck("name").map do |category|
      [category, "https://comic.pixiv.net/categories/#{Danbooru::URL.escape(category)}"]
    end

    tags += work.dig("official_work", "tags").to_a.pluck("name").map do |tag|
      [tag, "https://comic.pixiv.net/tags/#{Danbooru::URL.escape(tag)}"]
    end

    tags += [novel_work.dig("official_work", "novel_label", "name")].compact.map do |label|
      [label, "https://comic.pixiv.net/novel/categories/#{Danbooru::URL.escape(label)}"]
    end

    tags
  end

  def artist_commentary_title
    title = story["title"] || novel_story["title"] || work.dig("official_work", "name") || novel_work.dig("official_work", "name") || magazine.dig("magazine", "name")
    title&.normalize_whitespace
  end

  def artist_commentary_desc
    if story.present? || novel_story.present?
      nil
    elsif work.present?
      work.dig("official_work", "description")
    elsif novel_work.present?
      novel_work.dig("official_work", "description")
    elsif magazine.present?
      magazine.dig("magazine", "description")
    end
  end

  def dtext_artist_commentary_desc
    DText.from_html(artist_commentary_desc, base_url: "https://comic.pixiv.net")
  end

  def magazine_id
    parsed_url.magazine_id || parsed_referer&.magazine_id || work.dig("magazine", "id")
  end

  def work_id
    parsed_url.work_id || parsed_referer&.work_id || story["work_id"]
  end

  def story_id
    parsed_url.story_id || parsed_referer&.story_id
  end

  def novel_work_id
    parsed_url.novel_work_id || parsed_referer&.novel_work_id || novel_story["work_id"]
  end

  def novel_story_id
    parsed_url.novel_story_id || parsed_referer&.novel_story_id
  end

  memoize def magazine
    return {} unless magazine_id.present?

    http.cache(1.minute).parsed_get("https://comic.pixiv.net/api/app/magazines/v2/#{magazine_id}")&.dig("data") || {}
  end

  memoize def work
    return {} unless work_id.present?

    http.cache(1.minute).parsed_get("https://comic.pixiv.net/api/app/works/v5/#{work_id}")&.dig("data") || {}
  end

  memoize def work_stories
    return {} unless work_id.present?

    http.cache(1.minute).parsed_get("https://comic.pixiv.net/api/app/works/#{work_id}/episodes/v2?order=desc")&.dig("data", "episodes") || {}
  end

  memoize def story
    return {} unless story_id.present?

    http.cache(1.minute).parsed_get("https://comic.pixiv.net/api/app/episodes/#{story_id}/read_v4")&.dig("data", "reading_episode") || {}
  end

  memoize def novel_work
    return {} unless novel_work_id.present?

    http.cache(1.minute).parsed_get("https://comic.pixiv.net/api/app/novel/works/#{novel_work_id}")&.dig("data") || {}
  end

  memoize def novel_story
    return {} unless novel_story_id.present?

    http.cache(1.minute).parsed_get("https://comic.pixiv.net/api/app/novel/episodes/#{novel_story_id}/read_v4")&.dig("data", "reading_episode") || {}
  end

  def http
    time = Time.zone.now.rfc3339.to_s

    super.headers(
      "X-Requested-With": "pixivcomic",
      "X-Client-Hash": Digest::SHA256.hexdigest(time + CLIENT_HASH_SALT),
      "X-Client-Time": time
    )
  end
end
