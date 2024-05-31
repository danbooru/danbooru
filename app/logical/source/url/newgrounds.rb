# frozen_string_literal: true

# Unsupported:
#
# * https://www.newgrounds.com/portal/view/225625 (flash page)
# * https://uploads.ungrounded.net/225000/225625_colormedressup.swf?1111143751 (flash file)

class Source::URL::Newgrounds < Source::URL
  attr_reader :username, :work_id, :work_title, :project_id, :image_id, :video_id, :image_hash, :full_image_url, :candidate_full_image_urls

  def self.match?(url)
    url.domain.in?(["newgrounds.com", "ngfiles.com", "ungrounded.net"])
  end

  def parse
    case [host, *path_segments]

    # https://www.newgrounds.com/art/view/puddbytes/costanza-at-bat
    # https://www.newgrounds.com/art/view/natthelich/fire-emblem-marth-plus-progress-pic
    in "www.newgrounds.com", "art", "view", username, work_title
      @username = username
      @work_title = work_title

    # https://www.newgrounds.com/portal/view/536659
    # https://www.newgrounds.com/portal/video/536659 (curl 'https://www.newgrounds.com/portal/video/536659' -H 'X-Requested-With: XMLHttpRequest')
    in "www.newgrounds.com", "portal", ("view" | "video"), video_id
      @video_id = video_id

    # https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.1080p.mp4?1639666238
    # https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.720p.mp4?1639666238
    # https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.360p.mp4?1639666238
    in "uploads.ungrounded.net", "alternate", /^\d+$/ => subdir, /^\d+_alternate_\d+(?:\.\d+p)?\.mp4/ => file
      max_file = file.sub(/\.\d+p\./, ".")
      @full_image_url = "https://uploads.ungrounded.net/alternate/#{subdir}/#{max_file}"

    # https://art.ngfiles.com/medium_views/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.webp?f1702161430
    # https://art.ngfiles.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.jpg?f1702161372
    in "art.ngfiles.com", ("medium_views" | "images") => image_type, dir, /^(\d+)_(\d+)_([^_]+)_(.*)\.(\h{32})\.\w+$/
      @project_id = $1
      @image_id = $2
      @username = $3
      @work_title = $4
      @image_hash = $5

      if image_type == "images"
        @full_image_url = original_url.to_s
      else
        # Some full size images can have both .jpg and .webp versions. We assume the JPEG is superior.
        #
        # https://art.ngfiles.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.jpg?f1702161372
        # https://art.ngfiles.com/images/5267000/5267492_276880_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.1403130356bd217fb99f7ae3f9ce6029.webp?f1702161372
        @candidate_full_image_urls = %w[png jpg gif webp].map do |file_ext|
          original_url.to_s.gsub("/medium_views/", "/images/").gsub(".webp", ".#{file_ext}")
        end
      end

    # https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg
    # https://art.ngfiles.com/images/1033000/1033622_natthelich_fire-emblem-marth-plus-progress-pic.png?f1569487181
    in "art.ngfiles.com", "images", _, /^(\d+)_([^_]+)_(.*)\.\w+$/
      @work_id = $1
      @username = $2
      @work_title = $3
      @full_image_url = original_url

    # https://art.ngfiles.com/thumbnails/1254000/1254985.png?f1588263349
    in "art.ngfiles.com", "thumbnails", _, /^(\d+)\.\w+$/
      @work_id = $1
      @full_image_url = original_url

    # https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg
    in "art.ngfiles.com", "comments", _, /^iu/
      @full_image_url = original_url

    # https://natthelich.newgrounds.com
    # https://natthelich.newgrounds.com/art/
    in /^([a-z0-9-]+)\.newgrounds\.com$/, *rest if host != "www.newgrounds.com"
      @username = $1

    else
      nil
    end
  end

  # New: https://art.ngfiles.com/images/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595859
  # Old: https://art.ngfiles.com/images/3460000/3460312_nanobutts_throw-it-all-away.png?f1694804952
  def new_image_url?
    image_hash.present?
  end

  def image_url?
    url.host.in? ["art.ngfiles.com", "uploads.ungrounded.net"]
  end

  def page_url
    # XXX We can't always get the page URL from the image URL because the work title in the image URL might not be the
    # same as the title in the page URL.
    #
    # https://art.ngfiles.com/images/5225000/5225108_220662_nanobutts_untitled-5225108.4a602f9525d0d55d8add3dcfb1485507.webp?f1700595859
    # => https://www.newgrounds.com/art/view/nanobutts/vanilla-the-rabbit
    #
    # https://art.ngfiles.com/medium_views/5267000/5267492_276882_sphenodaile_princess-of-the-thorns-pages-9-10-afterwords.462b90641c2487627650683f5002c0be.webp?f1702161444
    # => https://www.newgrounds.com/art/view/sphenodaile/princess-of-the-thorns-pages-11-12-afterwords
    #
    # https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg
    # => https://www.newgrounds.com/art/view/natthelich/pandora-2 (revision?)
    if username.present? && work_title.present? && !new_image_url?
      "https://www.newgrounds.com/art/view/#{username}/#{work_title}"
    elsif video_id.present?
      "https://www.newgrounds.com/portal/view/#{video_id}"
    end
  end

  def profile_url
    "https://#{username}.newgrounds.com" if username.present?
  end
end
