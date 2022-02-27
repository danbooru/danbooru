# frozen_string_literal: true

# Image Urls
#
# * https://art.ngfiles.com/images/1543000/1543982_natthelich_pandora-2.jpg?f1607971817
# * https://art.ngfiles.com/images/1033000/1033622_natthelich_fire-emblem-marth-plus-progress-pic.png?f1569487181
#
# * https://www.newgrounds.com/art/view/natthelich/weaver (page)
# * https://art.ngfiles.com/images/1520000/1520217_natthelich_weaver.jpg?f1606365031
# * https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg
#
# Thumbnail URLs
#
# * https://art.ngfiles.com/thumbnails/1543000/1543982_full.png?f1607971901
# * https://art.ngfiles.com/thumbnails/1254000/1254985.png?f1588263349
#
# Page URLs
#
# * https://www.newgrounds.com/art/view/puddbytes/costanza-at-bat
# * https://www.newgrounds.com/art/view/natthelich/weaver (multiple)
#
# Video URLs
#
# * https://www.newgrounds.com/portal/view/825916 (page)
# * https://picon.ngfiles.com/825000/flash_825916_card.png?f1639666239 (poster)
# * https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.1080p.mp4?1639666238
# * https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.720p.mp4?1639666238
# * https://uploads.ungrounded.net/alternate/1801000/1801343_alternate_165104.360p.mp4?1639666238
#
# Flash URLs
#
# * https://www.newgrounds.com/portal/view/225625 (page)
# * https://uploads.ungrounded.net/225000/225625_colormedressup.swf?1111143751 (file)
#
# Other URLs
#
# * https://www.newgrounds.com/reviews/portal/1543982/4/
# * https://www.newgrounds.com/reviews/portal/1543982/4/score/1
# * https://www.newgrounds.com/content/share/1543982/4/
# * https://www.newgrounds.com/favorites/content/who/1543982/4
#
# Profile URLs
#
# * https://natthelich.newgrounds.com
# * https://natthelich.newgrounds.com/art
#
class Source::URL::Newgrounds < Source::URL
  attr_reader :username, :work_id, :work_title

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

    # https://art.ngfiles.com/images/1254000/1254722_natthelich_pandora.jpg
    # https://art.ngfiles.com/images/1033000/1033622_natthelich_fire-emblem-marth-plus-progress-pic.png?f1569487181
    in "art.ngfiles.com", "images", _, /^(\d+)_([^_]+)_(.*)\.\w+$/
      @work_id = $1
      @username = $2
      @work_title = $3

    # https://art.ngfiles.com/thumbnails/1254000/1254985.png?f1588263349
    in "art.ngfiles.com", "thumbnails", _, /^(\d+)\.\w+$/
      @work_id = $1

    # https://art.ngfiles.com/comments/57000/iu_57615_7115981.jpg
    in "art.ngfiles.com", "comments", _, /^iu/
      nil

    # https://natthelich.newgrounds.com
    # https://natthelich.newgrounds.com/art/
    in /^([a-z0-9-]+)\.newgrounds\.com$/, *rest if host != "www.newgrounds.com"
      @username = $1

    else
    end
  end

  def image_url?
    url.host == "art.ngfiles.com"
  end
end
