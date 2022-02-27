# frozen_string_literal: true

# Image URLs
#
# * http://pictures.hentai-foundry.com/a/Afrobull/795025/Afrobull-795025-kuroeda.png
# * http://pictures.hentai-foundry.com/_/-MadKaiser-/532792/-MadKaiser--532792-FFXIV_Miqote.png
# * http://pictures.hentai-foundry.com/p/PalomaP/855497/PalomaP-855497-Boooo..._bs..jpg
# * http://pictures.hentai-foundry.com//s/soranamae/363663.jpg
# * http://www.hentai-foundry.com/piccies/d/dmitrys/1183.jpg
#
# Page URLs
#
# * http://www.hentai-foundry.com/pictures/user/Afrobull/795025
# * http://www.hentai-foundry.com/pictures/user/Afrobull/795025/kuroeda
# * http://www.hentai-foundry.com/pictures/user/Ganassa/457176/LOL-Swimsuit---Caitlyn-reworked-nude-ver.
# * http://www.hentai-foundry.com/pic-795025
# * http://www.hentai-foundry.com/pic-149160.html
# * http://www.hentai-foundry.com/pic-149160.php
# * http://www.hentai-foundry.com/pic_full-66045.php
#
# Preview URLs
#
# * https://thumbs.hentai-foundry.com/thumb.php?pid=795025&size=350
#
# Profile URLs
#
# * https://www.hentai-foundry.com/user/kajinman/profile
# * https://www.hentai-foundry.com/pictures/user/kajinman
# * https://www.hentai-foundry.com/pictures/user/kajinman/scraps
# * https://www.hentai-foundry.com/user/J-likes-to-draw/profile
# * http://www.hentai-foundry.com/user-RockCandy.php
# * http://www.hentai-foundry.com/profile-sawao.php
#
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
end
