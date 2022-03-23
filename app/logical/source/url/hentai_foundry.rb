# frozen_string_literal: true

class Source::URL::HentaiFoundry < Source::URL
  attr_reader :username, :work_id

  def self.match?(url)
    url.domain == "hentai-foundry.com"
  end

  def parse
    case [host, *path_segments]

    # https://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png
    # https://pictures.hentai-foundry.com/_/-MadKaiser-/532792/-MadKaiser--532792-FFXIV_Miqote.png
    in "pictures.hentai-foundry.com", _, username, /^\d+$/ => work_id, slug
      @username = username
      @work_id = work_id

    # http://pictures.hentai-foundry.com//s/soranamae/363663.jpg
    in "pictures.hentai-foundry.com", _, username, /^(\d+)\.\w+$/
      @username = username
      @work_id = $1

    # http://www.hentai-foundry.com/piccies/d/dmitrys/1183.jpg
    in "www.hentai-foundry.com", "piccies", _, username, /^(\d+)\.\w+$/
      @username = username
      @work_id = $1

    # https://www.hentai-foundry.com/pictures/user/Afrobull/795025
    # https://www.hentai-foundry.com/pictures/user/Afrobull/795025/kuroeda
    in "www.hentai-foundry.com", "pictures", "user", username, /^\d+$/ => work_id, *slug
      @username = username
      @work_id = work_id

    # http://www.hentai-foundry.com/pic-795025
    # http://www.hentai-foundry.com/pic-149160.html
    # http://www.hentai-foundry.com/pic-149160.php
    # http://www.hentai-foundry.com/pic_full-66045.php
    in "www.hentai-foundry.com", /^pic\w*-(\d+)/
      @work_id = $1

    # https://thumbs.hentai-foundry.com/thumb.php?pid=795025&size=350
    in "thumbs.hentai-foundry.com", "thumb.php" if params[:pid].present?
      @work_id = params[:pid]

    # https://www.hentai-foundry.com/user/kajinman
    # https://www.hentai-foundry.com/user/kajinman/profile
    # https://www.hentai-foundry.com/user/J-likes-to-draw/profile
    in "www.hentai-foundry.com", "user", username, *slug
      @username = username

    # https://www.hentai-foundry.com/pictures/user/kajinman
    # https://www.hentai-foundry.com/pictures/user/kajinman/scraps
    in "www.hentai-foundry.com", "pictures", "user", username, *slug
      @username = username

    # http://www.hentai-foundry.com/user-RockCandy.php
    # http://www.hentai-foundry.com/profile-sawao.php
    in "www.hentai-foundry.com", /^(?:user|profile)-([^.]+)\.php$/
      @username = $1

    else
    end
  end

  def page_url
    if username.present? && work_id.present?
      "https://www.hentai-foundry.com/pictures/user/#{username}/#{work_id}"
    elsif work_id.present?
      "https://www.hentai-foundry.com/pic-#{work_id}"
    end
  end

  def profile_url
    "https://www.hentai-foundry.com/user/#{username}" if username.present?
  end
end
