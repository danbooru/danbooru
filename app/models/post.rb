require 'danbooru/has_bit_flags'

class Post < ApplicationRecord
  class ApprovalError < StandardError; end
  class DisapprovalError < StandardError; end
  class RevertError < StandardError; end
  class SearchError < StandardError; end
  class DeletionError < StandardError; end
  class TimeoutError < StandardError; end

  # Tags to copy when copying notes.
  NOTE_COPY_TAGS = %w[translated partially_translated check_translation translation_request reverse_translation]

  before_validation :initialize_uploader, :on => :create
  before_validation :merge_old_changes
  before_validation :normalize_tags
  before_validation :strip_source
  before_validation :parse_pixiv_id
  before_validation :blank_out_nonexistent_parents
  before_validation :remove_parent_loops
  validates_uniqueness_of :md5, :on => :create, message: ->(obj, data) { "duplicate: #{Post.find_by_md5(obj.md5).id}"}
  validates_inclusion_of :rating, in: %w(s q e), message: "rating must be s, q, or e"
  validate :added_tags_are_valid
  validate :removed_tags_are_valid
  validate :has_artist_tag
  validate :has_copyright_tag
  validate :has_enough_tags
  validate :post_is_not_its_own_parent
  validate :updater_can_change_rating
  validate :uploader_is_not_limited, on: :create
  before_save :update_tag_post_counts
  before_save :set_tag_counts
  before_create :autoban
  after_save :create_version
  after_save :update_parent_on_save
  after_save :apply_post_metatags
  after_commit :delete_files, :on => :destroy
  after_commit :remove_iqdb_async, :on => :destroy
  after_commit :update_iqdb_async, :on => :create

  belongs_to :updater, :class_name => "User", optional: true # this is handled in versions
  belongs_to :approver, class_name: "User", optional: true
  belongs_to :uploader, :class_name => "User", :counter_cache => "post_upload_count"
  belongs_to :parent, class_name: "Post", optional: true
  has_one :upload, :dependent => :destroy
  has_one :artist_commentary, :dependent => :destroy
  has_one :pixiv_ugoira_frame_data, :class_name => "PixivUgoiraFrameData", :dependent => :destroy
  has_many :flags, :class_name => "PostFlag", :dependent => :destroy
  has_many :appeals, :class_name => "PostAppeal", :dependent => :destroy
  has_many :votes, :class_name => "PostVote", :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :comments, -> {order("comments.id")}, :dependent => :destroy
  has_many :moderation_reports, through: :comments
  has_many :children, -> {order("posts.id")}, :class_name => "Post", :foreign_key => "parent_id"
  has_many :approvals, :class_name => "PostApproval", :dependent => :destroy
  has_many :disapprovals, :class_name => "PostDisapproval", :dependent => :destroy
  has_many :favorites
  has_many :replacements, class_name: "PostReplacement", :dependent => :destroy

  attr_accessor :old_tag_string, :old_parent_id, :old_source, :old_rating, :has_constraints, :disable_versioning, :view_count

  if PostArchive.enabled?
    has_many :versions, -> { Rails.env.test? ? order("post_versions.updated_at ASC, post_versions.id ASC") : order("post_versions.updated_at ASC") }, :class_name => "PostArchive", :dependent => :destroy
  end

  module FileMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def delete_files(post_id, md5, file_ext, force: false)
        if Post.where(md5: md5).exists? && !force
          raise DeletionError.new("Files still in use; skipping deletion.")
        end

        Danbooru.config.storage_manager.delete_file(post_id, md5, file_ext, :original)
        Danbooru.config.storage_manager.delete_file(post_id, md5, file_ext, :large)
        Danbooru.config.storage_manager.delete_file(post_id, md5, file_ext, :preview)

        Danbooru.config.backup_storage_manager.delete_file(post_id, md5, file_ext, :original)
        Danbooru.config.backup_storage_manager.delete_file(post_id, md5, file_ext, :large)
        Danbooru.config.backup_storage_manager.delete_file(post_id, md5, file_ext, :preview)
      end
    end

    def queue_delete_files(grace_period)
      DeletePostFilesJob.set(wait: grace_period).perform_later(id, md5, file_ext)
    end

    def delete_files
      Post.delete_files(id, md5, file_ext, force: true)
    end

    def distribute_files(file, sample_file, preview_file)
      storage_manager.store_file(file, self, :original)
      storage_manager.store_file(sample_file, self, :large) if sample_file.present?
      storage_manager.store_file(preview_file, self, :preview) if preview_file.present?

      backup_storage_manager.store_file(file, self, :original)
      backup_storage_manager.store_file(sample_file, self, :large) if sample_file.present?
      backup_storage_manager.store_file(preview_file, self, :preview) if preview_file.present?
    end

    def backup_storage_manager
      Danbooru.config.backup_storage_manager
    end

    def storage_manager
      Danbooru.config.storage_manager
    end

    def file(type = :original)
      storage_manager.open_file(self, type)
    end

    def tagged_file_url
      storage_manager.file_url(self, :original, tagged_filenames: !CurrentUser.user.disable_tagged_filenames?)
    end

    def tagged_large_file_url
      storage_manager.file_url(self, :large, tagged_filenames: !CurrentUser.user.disable_tagged_filenames?)
    end

    def file_url
      storage_manager.file_url(self, :original)
    end

    def large_file_url
      storage_manager.file_url(self, :large)
    end

    def preview_file_url
      storage_manager.file_url(self, :preview)
    end

    def file_path
      storage_manager.file_path(self, file_ext, :original)
    end

    def large_file_path
      storage_manager.file_path(self, file_ext, :large)
    end

    def preview_file_path
      storage_manager.file_path(self, file_ext, :preview)
    end

    def crop_file_url
      storage_manager.file_url(self, :crop)
    end

    def open_graph_image_url
      if is_image?
        if has_large?
          large_file_url
        else
          file_url
        end
      else
        preview_file_url
      end
    end

    def file_url_for(user)
      if user.default_image_size == "large" && image_width > Danbooru.config.large_image_width
        tagged_large_file_url
      else
        tagged_file_url
      end
    end

    def is_image?
      file_ext =~ /jpg|jpeg|gif|png/i
    end

    def is_png?
      file_ext =~ /png/i
    end

    def is_gif?
      file_ext =~ /gif/i
    end

    def is_flash?
      file_ext =~ /swf/i
    end

    def is_webm?
      file_ext =~ /webm/i
    end

    def is_mp4?
      file_ext =~ /mp4/i
    end

    def is_video?
      is_webm? || is_mp4?
    end

    def is_ugoira?
      file_ext =~ /zip/i
    end

    def has_preview?
      is_image? || is_video? || is_ugoira?
    end

    def has_dimensions?
      image_width.present? && image_height.present?
    end

    def has_ugoira_webm?
      true
    end
  end

  module ImageMethods
    def twitter_card_supported?
      image_width.to_i >= 280 && image_height.to_i >= 150
    end

    def has_large?
      return false if has_tag?("animated_gif|animated_png")
      return true if is_ugoira?
      is_image? && image_width.present? && image_width > Danbooru.config.large_image_width
    end

    alias has_large has_large?

    def large_image_width
      if has_large?
        [Danbooru.config.large_image_width, image_width].min
      else
        image_width
      end
    end

    def large_image_height
      ratio = Danbooru.config.large_image_width.to_f / image_width.to_f
      if has_large? && ratio < 1
        (image_height * ratio).to_i
      else
        image_height
      end
    end

    def image_width_for(user)
      if user.default_image_size == "large"
        large_image_width
      else
        image_width
      end
    end

    def image_height_for(user)
      if user.default_image_size == "large"
        large_image_height
      else
        image_height
      end
    end

    def resize_percentage
      100 * large_image_width.to_f / image_width.to_f
    end
  end

  module ApprovalMethods
    def is_approvable?(user = CurrentUser.user)
      !is_status_locked? && (is_pending? || is_flagged? || is_deleted?) && uploader != user && !approved_by?(user)
    end

    def flag!(reason, is_deletion: false)
      flag = flags.create(reason: reason, is_resolved: false, is_deletion: is_deletion, creator: CurrentUser.user)

      if flag.errors.any?
        raise PostFlag::Error.new(flag.errors.full_messages.join("; "))
      end
    end

    def approve!(approver = CurrentUser.user)
      approvals.create(user: approver)
    end

    def approved_by?(user)
      approver == user || approvals.where(user: user).exists?
    end

    def disapproved_by?(user)
      PostDisapproval.where(:user_id => user.id, :post_id => id).exists?
    end

    def autoban
      if has_tag?("banned_artist")
        self.is_banned = true
      end
    end
  end

  module PresenterMethods
    def presenter
      @presenter ||= PostPresenter.new(self)
    end

    def status_flags
      flags = []
      flags << "pending" if is_pending?
      flags << "flagged" if is_flagged?
      flags << "deleted" if is_deleted?
      flags << "banned" if is_banned?
      flags.join(" ")
    end

    def pretty_rating
      case rating
      when "q"
        "Questionable"

      when "e"
        "Explicit"

      when "s"
        "Safe"
      end
    end

    def normalized_source
      if pixiv_id.present?
        return "https://www.pixiv.net/artworks/#{pixiv_id}"
      end

      case source
      when %r{\Ahttps?://twitter.com/[^/]+/status/(\d+)\z}i
        "https://twitter.com/i/web/status/#{$1}"

      when %r{\Ahttps?://lohas\.nicoseiga\.jp/priv/(\d+)\?e=\d+&h=[a-f0-9]+}i,
           %r{\Ahttps?://lohas\.nicoseiga\.jp/priv/[a-f0-9]+/\d+/(\d+)}i
        "https://seiga.nicovideo.jp/seiga/im#{$1}"

      when %r{\Ahttps?://(?:d3j5vwomefv46c|dn3pm25xmtlyu)\.cloudfront\.net/photos/large/(\d+)\.}i
        base_10_id = $1.to_i
        base_36_id = base_10_id.to_s(36)
        "https://twitpic.com/#{base_36_id}"

      # http://prnt00.deviantart.net/9b74/b/2016/101/4/468a9d89f52a835d4f6f1c8caca0dfb2-pnjfbh.jpg
      # http://fc00.deviantart.net/fs71/f/2013/234/d/8/d84e05f26f0695b1153e9dab3a962f16-d6j8jl9.jpg
      # http://th04.deviantart.net/fs71/PRE/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg
      # http://fc09.deviantart.net/fs22/o/2009/197/3/7/37ac79eaeef9fb32e6ae998e9a77d8dd.jpg
      when %r{\Ahttps?://(?:fc|th|pre|orig|img|prnt)\d{2}\.deviantart\.net/.+/[a-f0-9]{32}-d(?<id>[a-z0-9]+)\.}i
        id = $~[:id].to_i(36)
        "https://deviantart.com/deviation/#{id}"

      when Sources::Strategies::DeviantArt::ASSET
        Sources::Strategies::DeviantArt.new(source).page_url_from_image_url || source

      when %r{\Ahttp://www\.karabako\.net/images(?:ub)?/karabako_(\d+)(?:_\d+)?\.}i
        "http://www.karabako.net/post/view/#{$1}"

      # XXX http://twipple.jp is defunct
      # http://p.twpl.jp/show/orig/myRVs
      when %r{\Ahttp://p\.twpl\.jp/show/(?:large|orig)/([a-z0-9]+)}i
        "http://p.twipple.jp/#{$1}"

      when %r{\Ahttps?://pictures\.hentai-foundry\.com//?[^/]/([^/]+)/(\d+)}i
        "https://www.hentai-foundry.com/pictures/user/#{$1}/#{$2}"

      when %r{\Ahttp://blog(?:(?:-imgs-)?\d*(?:-origin)?)?\.fc2\.com/(?:(?:[^/]/){3}|(?:[^/]/))([^/]+)/(?:file/)?([^\.]+\.[^\?]+)}i
        username = $1
        filename = $2
        "http://#{username}.blog.fc2.com/img/#{filename}/"

      when %r{\Ahttp://diary(\d)?\.fc2\.com/user/([^/]+)/img/(\d+)_(\d+)/(\d+)\.}i
        server_id = $1
        username = $2
        year = $3
        month = $4
        day = $5
        "http://diary#{server_id}.fc2.com/cgi-sys/ed.cgi/#{username}?Y=#{year}&M=#{month}&D=#{day}"

      when %r{\Ahttps?://(?:fbcdn-)?s(?:content|photos)-[^/]+\.(?:fbcdn|akamaihd)\.net/hphotos-.+/\d+_(\d+)_(?:\d+_){1,3}[no]\.}i
        "https://www.facebook.com/photo.php?fbid=#{$1}"

      when %r{\Ahttps?://c(?:s|han|[1-4])\.sankakucomplex\.com/data(?:/sample)?/(?:[a-f0-9]{2}/){2}(?:sample-|preview)?([a-f0-9]{32})}i
        "https://chan.sankakucomplex.com/en/post/show?md5=#{$1}"

      when %r{\Ahttp://s(?:tatic|[1-4])\.zerochan\.net/.+(?:\.|\/)(\d+)\.(?:jpe?g?)\z}i
        "https://www.zerochan.net/#{$1}#full"

      when %r{\Ahttp://static[1-6]?\.minitokyo\.net/(?:downloads|view)/(?:\d{2}/){2}(\d+)}i
        "http://gallery.minitokyo.net/download/#{$1}"

      # https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg
      # http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png
      # https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg
      when %r{\Ahttps?://(?:\w+\.)?gelbooru\.com//?(?:images|samples)/(?:\d+|\h\h/\h\h)/(?:sample_)?(?<md5>\h{32})\.}i
        "https://gelbooru.com/index.php?page=post&s=list&md5=#{$~[:md5]}"

      when %r{\Ahttps?://(?:slot\d*\.)?im(?:g|ages)\d*\.wikia\.(?:nocookie\.net|com)/(?:_{2}cb\d{14}/)?([^/]+)(?:/[a-z]{2})?/images/(?:(?:thumb|archive)?/)?[a-f0-9]/[a-f0-9]{2}/(?:\d{14}(?:!|%21))?([^/]+)}i
        subdomain = $1
        filename = $2
        "http://#{subdomain}.wikia.com/wiki/File:#{filename}"

      when %r{\Ahttps?://vignette(?:\d*)\.wikia\.nocookie\.net/([^/]+)/images/[a-f0-9]/[a-f0-9]{2}/([^/]+)}i
        subdomain = $1
        filename = $2
        "http://#{subdomain}.wikia.com/wiki/File:#{filename}"

      when %r{\Ahttp://(?:(?:\d{1,3}\.){3}\d{1,3}):(?:\d{1,5})/h/([a-f0-9]{40})-(?:\d+-){3}(?:png|gif|(?:jpe?g?))/keystamp=\d+-[a-f0-9]{10}/([^/]+)}i
        sha1hash = $1
        filename = $2
        "http://g.e-hentai.org/?f_shash=#{sha1hash}&fs_from=#{filename}"

      when %r{\Ahttp://e-shuushuu.net/images/\d{4}-(?:\d{2}-){2}(\d+)}i
        "http://e-shuushuu.net/image/#{$1}"

      when %r{\Ahttp://jpg\.nijigen-daiaru\.com/(\d+)}i
        "http://nijigen-daiaru.com/book.php?idb=#{$1}"

      when %r{\Ahttps?://sozai\.doujinantena\.com/contents_jpg/([a-f0-9]{32})/}i
        "http://doujinantena.com/page.php?id=#{$1}"

      when %r{\Ahttp://rule34-(?:data-\d{3}|images)\.paheal\.net/(?:_images/)?([a-f0-9]{32})}i
        "https://rule34.paheal.net/post/list/md5:#{$1}/1"

      when %r{\Ahttp://shimmie\.katawa-shoujo\.com/image/(\d+)}i
        "https://shimmie.katawa-shoujo.com/post/view/#{$1}"

      when %r{\Ahttp://(?:(?:(?:img\d?|cdn)\.)?rule34\.xxx|img\.booru\.org/(?:rule34|r34))(?:/(?:img/rule34|r34))?/{1,2}images/\d+/(?:[a-f0-9]{32}|[a-f0-9]{40})\.}i
        "https://rule34.xxx/index.php?page=post&s=list&md5=#{md5}"

      when %r{(\Ahttp://.+)/diarypro/d(?:ata/upfile/|iary\.cgi\?mode=image&upfile=)(\d+)}i
        base_url = $1
        entry_no = $2
        "#{base_url}/diarypro/diary.cgi?no=#{entry_no}"

      # XXX site is defunct
      when %r{\Ahttp://i(?:\d)?\.minus\.com/(?:i|j)([^\.]{12,})}i
        "http://minus.com/i/#{$1}"

      when %r{\Ahttps?://pic0[1-4]\.nijie\.info/nijie_picture/(?:diff/main/)?\d+_(\d+)_(?:\d+{10}|\d+_\d+{14})}i
        "https://nijie.info/view.php?id=#{$1}"

      # http://ayase.yande.re/image/2d0d229fd8465a325ee7686fcc7f75d2/yande.re%20192481%20animal_ears%20bunny_ears%20garter_belt%20headphones%20mitha%20stockings%20thighhighs.jpg
      # https://yuno.yande.re/image/1764b95ae99e1562854791c232e3444b/yande.re%20281544%20cameltoe%20erect_nipples%20fundoshi%20horns%20loli%20miyama-zero%20sarashi%20sling_bikini%20swimsuits.jpg
      # https://files.yande.re/image/2a5d1d688f565cb08a69ecf4e35017ab/yande.re%20349790%20breast_hold%20kurashima_tomoyasu%20mahouka_koukou_no_rettousei%20naked%20nipples.jpg
      # https://files.yande.re/sample/0d79447ce2c89138146f64ba93633568/yande.re%20290757%20sample%20seifuku%20thighhighs%20tsukudani_norio.jpg
      when %r{\Ahttps?://(?:[^.]+\.)?yande\.re/(?:image|jpeg|sample)/\h{32}/yande\.re%20(?<post_id>\d+)}i
        "https://yande.re/post/show/#{$~[:post_id]}"

      # https://yande.re/jpeg/0c9ec0ffcaa40470093cb44c3fd40056/yande.re%2064649%20animal_ears%20cameltoe%20fixme%20nekomimi%20nipples%20ryohka%20school_swimsuit%20see_through%20shiraishi_nagomi%20suzuya%20swimsuits%20tail%20thighhighs.jpg
      # https://yande.re/jpeg/22577d2344fe694cf47f80563031b3cd.jpg
      # https://yande.re/image/b4b1d11facd1700544554e4805d47bb6/.png
      # https://yande.re/sample/ceb6a12e87945413a95b90fada406f91/.jpg
      when %r{\Ahttps?://(?:[^.]+\.)?yande\.re/(?:image|jpeg|sample)/(?<md5>\h{32})(?:/yande\.re.*|/?\.(?:jpg|png))\z}i
        "https://yande.re/post?tags=md5:#{$~[:md5]}"

      when %r{\Ahttps?://(?:[^.]+\.)?konachan\.com/(?:image|jpeg|sample)/\h{32}/Konachan\.com%20-%20(?<post_id>\d+)}i
        "https://konachan.com/post/show/#{$~[:post_id]}"

      when %r{\Ahttps?://(?:[^.]+\.)?konachan\.com/(?:image|jpeg|sample)/(?<md5>\h{32})(?:/Konachan\.com%20-%20.*|/?\.(?:jpg|png))\z}i
        "https://konachan.com/post?tags=md5:#{$~[:md5]}"

      # https://gfee_li.artstation.com/projects/XPGOD
      # https://gfee_li.artstation.com/projects/asuka-7
      when %r{\Ahttps?://\w+\.artstation.com/(?:artwork|projects)/(?<project_id>[a-z0-9-]+)\z/}i
        "https://www.artstation.com/artwork/#{$~[:project_id]}"

      when %r{\Ahttps?://(?:o|image-proxy-origin)\.twimg\.com/\d/proxy\.jpg\?t=(\w+)&}i
        str = Base64.decode64($1)
        url = URI.extract(str, ['http', 'https'])
        if url.any?
          url = url[0]
          if url =~ /^https?:\/\/twitpic.com\/show\/large\/[a-z0-9]+/i
            url.gsub!(/show\/large\//, "")
            index = url.rindex('.')
            url = url[0..index - 1]
          end
          url
        else
          source
        end

      # http://art59.photozou.jp/pub/212/1986212/photo/118493247_org.v1534644005.jpg
      # http://kura3.photozou.jp/pub/794/1481794/photo/161537258_org.v1364829097.jpg
      when %r{\Ahttps?://\w+\.photozou\.jp/pub/\d+/(?<artist_id>\d+)/photo/(?<photo_id>\d+)_.*$}i
        "https://photozou.jp/photo/show/#{$~[:artist_id]}/#{$~[:photo_id]}"

      # http://img.toranoana.jp/popup_img/04/0030/09/76/040030097695-2p.jpg
      # http://img.toranoana.jp/popup_img18/04/0010/22/87/040010228714-1p.jpg
      # http://img.toranoana.jp/popup_blimg/04/0030/08/30/040030083068-1p.jpg
      # https://ecdnimg.toranoana.jp/ec/img/04/0030/65/34/040030653417-6p.jpg
      when %r{\Ahttps?://(\w+\.)?toranoana\.jp/(?:popup_(?:bl)?img\d*|ec/img)/\d{2}/\d{4}/\d{2}/\d{2}/(?<work_id>\d+)}i
        "https://ec.toranoana.jp/tora_r/ec/item/#{$~[:work_id]}/"

      # https://a.hitomi.la/galleries/907838/1.png
      # https://0a.hitomi.la/galleries/1169701/23.png
      # https://aa.hitomi.la/galleries/990722/003_01_002.jpg
      # https://la.hitomi.la/galleries/1054851/001_main_image.jpg
      when %r{\Ahttps?://\w+\.hitomi\.la/galleries/(?<gallery_id>\d+)/(?<image_id>\d+)\w*\.[a-z]+\z}i
        "https://hitomi.la/reader/#{$~[:gallery_id]}.html##{$~[:image_id].to_i}"

      # https://aa.hitomi.la/galleries/883451/t_rena1g.png
      when %r{\Ahttps?://\w+\.hitomi\.la/galleries/(?<gallery_id>\d+)/\w*\.[a-z]+\z}i
        "https://hitomi.la/galleries/#{$~[:gallery_id]}.html"

      else
        source
      end
    end

    def source_domain
      return "" unless source =~ %r!\Ahttps?://!i

      url = Addressable::URI.parse(normalized_source)
      url.domain
    rescue StandardError
      ""
    end
  end

  module TagMethods
    def tag_array
      @tag_array ||= Tag.scan_tags(tag_string)
    end

    def tag_array_was
      @tag_array_was ||= Tag.scan_tags(tag_string_in_database.presence || tag_string_before_last_save || "")
    end

    def tags
      Tag.where(name: tag_array)
    end

    def tags_was
      Tag.where(name: tag_array_was)
    end

    def added_tags
      tags - tags_was
    end

    def decrement_tag_post_counts
      Tag.where(:name => tag_array).update_all("post_count = post_count - 1") if tag_array.any?
    end

    def update_tag_post_counts
      decrement_tags = tag_array_was - tag_array

      decrement_tags_except_requests = decrement_tags.reject {|tag| tag == "tagme" || tag.end_with?("_request")}
      if !decrement_tags_except_requests.empty? && !CurrentUser.is_builder? && CurrentUser.created_at > 1.week.ago
        self.errors.add(:updater_id, "must have an account at least 1 week old to remove tags")
        return false
      end

      increment_tags = tag_array - tag_array_was
      if increment_tags.any?
        Tag.increment_post_counts(increment_tags)
      end
      if decrement_tags.any?
        Tag.decrement_post_counts(decrement_tags)
      end
    end

    def set_tag_count(category, tagcount)
      self.send("tag_count_#{category}=", tagcount)
    end

    def inc_tag_count(category)
      set_tag_count(category, self.send("tag_count_#{category}") + 1)
    end

    def set_tag_counts(disable_cache = true)
      self.tag_count = 0
      TagCategory.categories.each {|x| set_tag_count(x, 0)}
      categories = Tag.categories_for(tag_array, :disable_caching => disable_cache)
      categories.each_value do |category|
        self.tag_count += 1
        inc_tag_count(TagCategory.reverse_mapping[category])
      end
    end

    def merge_old_changes
      reset_tag_array_cache
      @removed_tags = []

      if old_tag_string
        # If someone else committed changes to this post before we did,
        # then try to merge the tag changes together.
        current_tags = tag_array_was
        new_tags = tag_array
        old_tags = Tag.scan_tags(old_tag_string)

        kept_tags = current_tags & new_tags
        @removed_tags = old_tags - kept_tags

        set_tag_string(((current_tags + new_tags) - old_tags + (current_tags & new_tags)).uniq.sort.join(" "))
      end

      if old_parent_id == ""
        old_parent_id = nil
      else
        old_parent_id = old_parent_id.to_i
      end
      if old_parent_id == parent_id
        self.parent_id = parent_id_before_last_save || parent_id_was
      end

      if old_source == source.to_s
        self.source = source_before_last_save || source_was
      end

      if old_rating == rating
        self.rating = rating_before_last_save || rating_was
      end
    end

    def reset_tag_array_cache
      @tag_array = nil
      @tag_array_was = nil
    end

    def set_tag_string(string)
      self.tag_string = string
      reset_tag_array_cache
    end

    def normalize_tags
      normalized_tags = Tag.scan_tags(tag_string)
      normalized_tags = apply_casesensitive_metatags(normalized_tags)
      normalized_tags = normalized_tags.map(&:downcase)
      normalized_tags = filter_metatags(normalized_tags)
      normalized_tags = remove_negated_tags(normalized_tags)
      normalized_tags = TagAlias.to_aliased(normalized_tags)
      normalized_tags = %w(tagme) if normalized_tags.empty?
      normalized_tags = add_automatic_tags(normalized_tags)
      normalized_tags = remove_invalid_tags(normalized_tags)
      normalized_tags = Tag.convert_cosplay_tags(normalized_tags)
      normalized_tags += Tag.create_for_list(TagImplication.automatic_tags_for(normalized_tags))
      normalized_tags = TagImplication.with_descendants(normalized_tags)
      normalized_tags = normalized_tags.compact.uniq.sort
      normalized_tags = Tag.create_for_list(normalized_tags)
      set_tag_string(normalized_tags.join(" "))
    end

    def remove_invalid_tags(tag_names)
      invalid_tags = tag_names.map { |name| Tag.new(name: name) }.select { |tag| tag.invalid?(:name) }

      invalid_tags.each do |tag|
        tag.errors.messages.each do |attribute, messages|
          warnings[:base] << "Couldn't add tag: #{messages.join(';')}"
        end
      end

      tag_names - invalid_tags.map(&:name)
    end

    def remove_negated_tags(tags)
      @negated_tags, tags = tags.partition {|x| x =~ /\A-/i}
      @negated_tags = @negated_tags.map {|x| x[1..-1]}
      @negated_tags = TagAlias.to_aliased(@negated_tags)
      return tags - @negated_tags
    end

    def add_automatic_tags(tags)
      tags -= %w(incredibly_absurdres absurdres highres lowres huge_filesize flash webm mp4)

      if has_dimensions?
        if image_width >= 10_000 || image_height >= 10_000
          tags << "incredibly_absurdres"
        end
        if image_width >= 3200 || image_height >= 2400
          tags << "absurdres"
        end
        if image_width >= 1600 || image_height >= 1200
          tags << "highres"
        end
        if image_width <= 500 && image_height <= 500
          tags << "lowres"
        end

        if image_width >= 1024 && image_width.to_f / image_height >= 4
          tags << "wide_image"
          tags << "long_image"
        elsif image_height >= 1024 && image_height.to_f / image_width >= 4
          tags << "tall_image"
          tags << "long_image"
        end
      end

      if file_size >= 10.megabytes
        tags << "huge_filesize"
      end

      if is_flash?
        tags << "flash"
      end

      if is_webm?
        tags << "webm"
      end

      if is_mp4?
        tags << "mp4"
      end

      if is_ugoira?
        tags << "ugoira"
      end

      if !is_gif?
        tags -= ["animated_gif"]
      end

      if !is_png?
        tags -= ["animated_png"]
      end

      return tags
    end

    def apply_casesensitive_metatags(tags)
      casesensitive_metatags, tags = tags.partition {|x| x =~ /\A(?:source):/i}
      # Reuse the following metatags after the post has been saved
      casesensitive_metatags += tags.select {|x| x =~ /\A(?:newpool):/i}
      if !casesensitive_metatags.empty?
        case casesensitive_metatags[-1]
        when /^source:none$/i
          self.source = ""

        when /^source:"(.*)"$/i
          self.source = $1

        when /^source:(.*)$/i
          self.source = $1

        when /^newpool:(.+)$/i
          pool = Pool.find_by_name($1)
          if pool.nil?
            pool = Pool.create(name: $1, creator: CurrentUser.user, description: "This pool was automatically generated")
          end
        end
      end
      return tags
    end

    def filter_metatags(tags)
      @pre_metatags, tags = tags.partition {|x| x =~ /\A(?:rating|parent|-parent|-?locked):/i}
      tags = apply_categorization_metatags(tags)
      @post_metatags, tags = tags.partition {|x| x =~ /\A(?:-pool|pool|newpool|fav|-fav|child|-child|-favgroup|favgroup|upvote|downvote):/i}
      apply_pre_metatags
      return tags
    end

    def apply_categorization_metatags(tags)
      tags.map do |x|
        if x =~ Tag.categories.regexp
          tag = Tag.find_or_create_by_name(x)
          tag.name
        else
          x
        end
      end
    end

    def apply_post_metatags
      return unless @post_metatags

      @post_metatags.each do |tag|
        case tag
        when /^-pool:(\d+)$/i
          pool = Pool.find_by_id($1.to_i)
          remove_pool!(pool) if pool

        when /^-pool:(.+)$/i
          pool = Pool.find_by_name($1)
          remove_pool!(pool) if pool

        when /^pool:(\d+)$/i
          pool = Pool.find_by_id($1.to_i)
          add_pool!(pool) if pool

        when /^pool:(.+)$/i
          pool = Pool.find_by_name($1)
          add_pool!(pool) if pool

        when /^newpool:(.+)$/i
          pool = Pool.find_by_name($1)
          add_pool!(pool) if pool

        when /^fav:(.+)$/i
          add_favorite!(CurrentUser.user)

        when /^-fav:(.+)$/i
          remove_favorite!(CurrentUser.user)

        when /^(up|down)vote:(.+)$/i
          vote!($1)

        when /^child:none$/i
          children.each do |post|
            post.update!(parent_id: nil)
          end

        when /^-child:(.+)$/i
          children.numeric_attribute_matches(:id, $1).each do |post|
            post.update!(parent_id: nil)
          end

        when /^child:(.+)$/i
          Post.numeric_attribute_matches(:id, $1).where.not(id: id).limit(10).each do |post|
            post.update!(parent_id: id)
          end

        when /^-favgroup:(.+)$/i
          favgroup = FavoriteGroup.find_by_name_or_id!($1, CurrentUser.user)
          raise User::PrivilegeError unless favgroup.editable_by?(CurrentUser.user)
          favgroup&.remove!(self)

        when /^favgroup:(.+)$/i
          favgroup = FavoriteGroup.find_by_name_or_id!($1, CurrentUser.user)
          raise User::PrivilegeError unless favgroup.editable_by?(CurrentUser.user)
          favgroup&.add!(self)

        end
      end
    end

    def apply_pre_metatags
      return unless @pre_metatags

      @pre_metatags.each do |tag|
        case tag
        when /^parent:none$/i, /^parent:0$/i
          self.parent_id = nil

        when /^-parent:(\d+)$/i
          if parent_id == $1.to_i
            self.parent_id = nil
          end

        when /^parent:(\d+)$/i
          if $1.to_i != id && Post.exists?(["id = ?", $1.to_i])
            self.parent_id = $1.to_i
            remove_parent_loops
          end

        when /^rating:([qse])/i
          self.rating = $1

        when /^(-?)locked:notes?$/i
          self.is_note_locked = ($1 != "-") if CurrentUser.is_builder?

        when /^(-?)locked:rating$/i
          self.is_rating_locked = ($1 != "-") if CurrentUser.is_builder?

        when /^(-?)locked:status$/i
          self.is_status_locked = ($1 != "-") if CurrentUser.is_admin?

        end
      end
    end

    def has_tag?(tag)
      tag_string.match?(/(?:^| )(?:#{tag})(?:$| )/)
    end

    def add_tag(tag)
      set_tag_string("#{tag_string} #{tag}")
    end

    def remove_tag(tag)
      set_tag_string((tag_array - Array(tag)).join(" "))
    end

    def tag_categories
      @tag_categories ||= Tag.categories_for(tag_array)
    end

    def typed_tags(name)
      @typed_tags ||= {}
      @typed_tags[name] ||= begin
        tag_array.select do |tag|
          tag_categories[tag] == TagCategory.mapping[name]
        end
      end
    end

    TagCategory.categories.each do |category|
      define_method("tag_string_#{category}") do
        typed_tags(category).join(" ")
      end
    end
  end

  module FavoriteMethods
    def clean_fav_string?
      true
    end

    def clean_fav_string!
      array = fav_string.split.uniq
      self.fav_string = array.join(" ")
      self.fav_count = array.size
      update_column(:fav_string, fav_string)
      update_column(:fav_count, fav_count)
    end

    def favorited_by?(user_id = CurrentUser.id)
      fav_string.match?(/(?:\A| )fav:#{user_id}(?:\Z| )/)
    end

    alias is_favorited? favorited_by?

    def append_user_to_fav_string(user_id)
      update_column(:fav_string, (fav_string + " fav:#{user_id}").strip)
      clean_fav_string! if clean_fav_string?
    end

    def add_favorite(user)
      add_favorite!(user)
      true
    rescue Favorite::Error
      false
    end

    def add_favorite!(user)
      Favorite.add(post: self, user: user)
      vote!("up", user) if user.is_voter?
    rescue PostVote::Error
    end

    def delete_user_from_fav_string(user_id)
      update_column(:fav_string, fav_string.gsub(/(?:\A| )fav:#{user_id}(?:\Z| )/, " ").strip)
    end

    def remove_favorite!(user)
      Favorite.remove(post: self, user: user)
      unvote!(user) if user.is_voter?
    rescue PostVote::Error
    end

    # users who favorited this post, ordered by users who favorited it first
    def favorited_users
      favorited_user_ids = fav_string.scan(/\d+/).map(&:to_i)
      visible_users = User.find(favorited_user_ids).reject(&:hide_favorites?)
      ordered_users = visible_users.index_by(&:id).slice(*favorited_user_ids).values
      ordered_users
    end

    def favorite_groups
      FavoriteGroup.for_post(id)
    end

    def remove_from_favorites
      Favorite.where(post_id: id).delete_all
      user_ids = fav_string.scan(/\d+/)
      User.where(:id => user_ids).update_all("favorite_count = favorite_count - 1")
      PostVote.where(post_id: id).delete_all
    end

    def remove_from_fav_groups
      FavoriteGroup.for_post(id).find_each do |favgroup|
        favgroup.remove!(self)
      end
    end
  end

  module UploaderMethods
    def initialize_uploader
      if uploader_id.blank?
        self.uploader_id = CurrentUser.id
        self.uploader_ip_addr = CurrentUser.ip_addr
      end
    end

    def uploader_name
      uploader.name
    end
  end

  module PoolMethods
    def pools
      Pool.where("pools.post_ids && array[?]", id)
    end

    def has_active_pools?
      !pools.undeleted.empty?
    end

    def belongs_to_pool?(pool)
      pool_string =~ /(?:\A| )pool:#{pool.id}(?:\Z| )/
    end

    def belongs_to_pool_with_id?(pool_id)
      pool_string =~ /(?:\A| )pool:#{pool_id}(?:\Z| )/
    end

    def add_pool!(pool, force = false)
      return if belongs_to_pool?(pool)
      return if pool.is_deleted? && !force

      with_lock do
        self.pool_string = "#{pool_string} pool:#{pool.id}".strip
        update_column(:pool_string, pool_string) unless new_record?
        pool.add!(self)
      end
    end

    def remove_pool!(pool)
      return unless belongs_to_pool?(pool)
      return unless CurrentUser.user.can_remove_from_pools?

      with_lock do
        self.pool_string = pool_string.gsub(/(?:\A| )pool:#{pool.id}(?:\Z| )/, " ").strip
        update_column(:pool_string, pool_string) unless new_record?
        pool.remove!(self)
      end
    end

    def remove_from_all_pools
      pools.find_each do |pool|
        pool.remove!(self)
      end
    end
  end

  module VoteMethods
    def can_be_voted_by?(user)
      !PostVote.exists?(:user_id => user.id, :post_id => id)
    end

    def vote!(vote, voter = CurrentUser.user)
      unless voter.is_voter?
        raise PostVote::Error.new("You do not have permission to vote")
      end

      unless can_be_voted_by?(voter)
        raise PostVote::Error.new("You have already voted for this post")
      end

      votes.create!(user: voter, vote: vote)
      reload # PostVote.create modifies our score. Reload to get the new score.
    end

    def unvote!(voter = CurrentUser.user)
      if can_be_voted_by?(voter)
        raise PostVote::Error.new("You have not voted for this post")
      else
        votes.where(user: voter).destroy_all
        reload
      end
    end
  end

  module CountMethods
    def fast_count(tags = "", timeout: 1_000, raise_on_timeout: false, skip_cache: false)
      tags = tags.to_s
      tags += " rating:s" if CurrentUser.safe_mode?
      tags += " -status:deleted" if CurrentUser.hide_deleted_posts? && !Tag.has_metatag?(tags, "status", "-status")
      tags = Tag.normalize_query(tags)

      # Optimize some cases. these are just estimates but at these
      # quantities being off by a few hundred doesn't matter much
      if Danbooru.config.estimate_post_counts
        if tags == ""
          return (Post.maximum(:id).to_i * (2200402.0 / 2232212)).floor

        elsif tags =~ /^rating:s(?:afe)?$/
          return (Post.maximum(:id).to_i * (1648652.0 / 2200402)).floor

        elsif tags =~ /^rating:q(?:uestionable)?$/
          return (Post.maximum(:id).to_i * (350101.0 / 2200402)).floor

        elsif tags =~ /^rating:e(?:xplicit)?$/
          return (Post.maximum(:id).to_i * (201650.0 / 2200402)).floor

        end
      end

      count = nil

      unless skip_cache
        count = get_count_from_cache(tags)
      end

      if count.nil?
        count = fast_count_search(tags, timeout: timeout, raise_on_timeout: raise_on_timeout)
      end

      count
    rescue SearchError
      0
    end

    def fast_count_search(tags, timeout:, raise_on_timeout:)
      count = Post.with_timeout(timeout, nil, tags: tags) do
        Post.tag_match(tags).count
      end

      if count.nil?
        # give up
        if raise_on_timeout
          raise TimeoutError.new("timed out")
        end

        count = Danbooru.config.blank_tag_search_fast_count
      else
        set_count_in_cache(tags, count)
      end

      count ? count.to_i : nil
    rescue PG::ConnectionBad
      return nil
    end

    def fix_post_counts(post)
      post.set_tag_counts(false)
      if post.changes_saved?
        args = Hash[TagCategory.categories.map {|x| ["tag_count_#{x}", post.send("tag_count_#{x}")]}].update(:tag_count => post.tag_count)
        post.update_columns(args)
      end
    end

    def get_count_from_cache(tags)
      if Tag.is_simple_tag?(tags)
        count = Tag.find_by(name: tags).try(:post_count)
      else
        # this will only have a value for multi-tag searches or single metatag searches
        count = Cache.get(count_cache_key(tags))
      end

      count.try(:to_i)
    end

    def set_count_in_cache(tags, count, expiry = nil)
      expiry ||= count.seconds.clamp(3.minutes, 20.hours).to_i

      Cache.put(count_cache_key(tags), count, expiry)
    end

    def count_cache_key(tags)
      "pfc:#{Cache.hash(tags)}"
    end
  end

  module ParentMethods
    # A parent has many children. A child belongs to a parent.
    # A parent cannot have a parent.
    #
    # After expunging a child:
    # - Move favorites to parent.
    # - Does the parent have any children?
    #   - Yes: Done.
    #   - No: Update parent's has_children flag to false.
    #
    # After expunging a parent:
    # - Move favorites to the first child.
    # - Reparent all children to the first child.

    def update_has_children_flag
      update(has_children: children.exists?, has_active_children: children.undeleted.exists?)
    end

    def blank_out_nonexistent_parents
      if parent_id.present? && parent.nil?
        self.parent_id = nil
      end
    end

    def remove_parent_loops
      if parent.present? && parent.parent_id.present? && parent.parent_id == id
        parent.parent_id = nil
        parent.save
      end
    end

    def update_parent_on_destroy
      parent&.update_has_children_flag
    end

    def update_children_on_destroy
      return unless children.present?

      eldest = children[0]
      siblings = children[1..-1]

      eldest.update(parent_id: nil)
      Post.where(id: siblings).find_each { |p| p.update(parent_id: eldest.id) }
      # Post.where(id: siblings).update(parent_id: eldest.id) # XXX rails 5
    end

    def update_parent_on_save
      return unless saved_change_to_parent_id? || saved_change_to_is_deleted?

      parent.update_has_children_flag if parent.present?
      Post.find(parent_id_before_last_save).update_has_children_flag if parent_id_before_last_save.present?
    end

    def give_favorites_to_parent(options = {})
      return if parent.nil?

      transaction do
        favorites.each do |fav|
          remove_favorite!(fav.user)
          parent.add_favorite(fav.user)
        end
      end

      unless options[:without_mod_action]
        ModAction.log("moved favorites from post ##{id} to post ##{parent.id}", :post_move_favorites)
      end
    end

    def has_visible_children?
      return true if has_active_children?
      return true if has_children? && CurrentUser.user.show_deleted_children?
      return true if has_children? && is_deleted?
      return false
    end

    def has_visible_children
      has_visible_children?
    end

    def children_ids
      if has_children?
        children.map(&:id).join(' ')
      end
    end
  end

  module DeletionMethods
    def expunge!
      if is_status_locked?
        self.errors.add(:is_status_locked, "; cannot delete post")
        return false
      end

      transaction do
        Post.without_timeout do
          ModAction.log("permanently deleted post ##{id}", :post_permanent_delete)

          give_favorites_to_parent
          update_children_on_destroy
          decrement_tag_post_counts
          remove_from_all_pools
          remove_from_fav_groups
          remove_from_favorites
          destroy
          update_parent_on_destroy
        end
      end
    end

    def ban!
      update_column(:is_banned, true)
      ModAction.log("banned post ##{id}", :post_ban)
    end

    def unban!
      update_column(:is_banned, false)
      ModAction.log("unbanned post ##{id}", :post_unban)
    end

    def delete!(reason, options = {})
      if is_status_locked?
        self.errors.add(:is_status_locked, "; cannot delete post")
        return false
      end

      Post.transaction do
        flag!(reason, is_deletion: true)

        update(
          is_deleted: true,
          is_pending: false,
          is_flagged: false,
          is_banned: is_banned || options[:ban] || has_tag?("banned_artist")
        )

        # XXX This must happen *after* the `is_deleted` flag is set to true (issue #3419).
        give_favorites_to_parent(options) if options[:move_favorites]

        is_automatic = (reason == "Unapproved in three days")
        uploader.upload_limit.update_limit!(self, incremental: is_automatic)

        unless options[:without_mod_action]
          ModAction.log("deleted post ##{id}, reason: #{reason}", :post_delete)
        end
      end
    end

    def replace!(params)
      transaction do
        replacement = replacements.create(params)
        processor = UploadService::Replacer.new(post: self, replacement: replacement)
        processor.process!
        replacement
      end
    end
  end

  module VersionMethods
    def create_version(force = false)
      if new_record? || saved_change_to_watched_attributes? || force
        create_new_version
      end
    end

    def saved_change_to_watched_attributes?
      saved_change_to_rating? || saved_change_to_source? || saved_change_to_parent_id? || saved_change_to_tag_string?
    end

    def merge_version?
      prev = versions.last
      prev && prev.updater_id == CurrentUser.user.id && prev.updated_at > 1.hour.ago
    end

    def create_new_version
      User.where(id: CurrentUser.id).update_all("post_update_count = post_update_count + 1")
      PostArchive.queue(self) if PostArchive.enabled?
    end

    def revert_to(target)
      if id != target.post_id
        raise RevertError.new("You cannot revert to a previous version of another post.")
      end

      self.tag_string = target.tags
      self.rating = target.rating
      self.source = target.source
      self.parent_id = target.parent_id
    end

    def revert_to!(target)
      revert_to(target)
      save!
    end
  end

  module NoteMethods
    def has_notes?
      last_noted_at.present?
    end

    def copy_notes_to(other_post, copy_tags: NOTE_COPY_TAGS)
      transaction do
        if id == other_post.id
          errors.add :base, "Source and destination posts are the same"
          return false
        end
        unless has_notes?
          errors.add :post, "has no notes"
          return false
        end

        notes.active.each do |note|
          note.copy_to(other_post)
        end

        dummy = Note.new
        if notes.active.length == 1
          dummy.body = "Copied 1 note from post ##{id}."
        else
          dummy.body = "Copied #{notes.active.length} notes from post ##{id}."
        end
        dummy.is_active = false
        dummy.post_id = other_post.id
        dummy.x = dummy.y = dummy.width = dummy.height = 0
        dummy.save

        copy_tags.each do |tag|
          other_post.remove_tag(tag)
          other_post.add_tag(tag) if has_tag?(tag)
        end

        other_post.has_embedded_notes = has_embedded_notes
        other_post.save
      end
    end
  end

  module ApiMethods
    def api_attributes
      attributes = super
      attributes += [:uploader_name, :has_large, :has_visible_children, :children_ids, :is_favorited?] + TagCategory.categories.map {|x| "tag_string_#{x}".to_sym}
      attributes += [:file_url, :large_file_url, :preview_file_url] if visible?
      attributes -= [:md5, :file_ext] if !visible?
      attributes -= [:fav_string] if !CurrentUser.is_moderator?
      attributes
    end

    def associated_attributes
      [:pixiv_ugoira_frame_data]
    end

    def as_json(options = {})
      options ||= {}
      options[:include] ||= []
      options[:include] += associated_attributes
      super(options)
    end

    def legacy_attributes
      hash = {
        "has_comments" => last_commented_at.present?,
        "parent_id" => parent_id,
        "status" => status,
        "has_children" => has_children?,
        "created_at" => created_at.to_formatted_s(:db),
        "has_notes" => has_notes?,
        "rating" => rating,
        "author" => uploader.name,
        "creator_id" => uploader_id,
        "width" => image_width,
        "source" => source,
        "score" => score,
        "tags" => tag_string,
        "height" => image_height,
        "file_size" => file_size,
        "id" => id
      }

      if visible?
        hash["file_url"] = file_url
        hash["preview_url"] = preview_file_url
        hash["md5"] = md5
      end

      hash
    end

    def status
      if is_pending?
        "pending"
      elsif is_deleted?
        "deleted"
      elsif is_flagged?
        "flagged"
      else
        "active"
      end
    end
  end

  module SearchMethods
    # returns one single post
    def random
      key = Digest::MD5.hexdigest(Time.now.to_f.to_s)
      random_up(key) || random_down(key)
    end

    def random_up(key)
      where("md5 < ?", key).reorder("md5 desc").first
    end

    def random_down(key)
      where("md5 >= ?", key).reorder("md5 asc").first
    end

    def sample(query, sample_size)
      CurrentUser.without_safe_mode do
        tag_match(query).reorder(:md5).limit(sample_size)
      end
    end

    # unflattens the tag_string into one tag per row.
    def with_unflattened_tags
      joins("CROSS JOIN unnest(string_to_array(tag_string, ' ')) AS tag")
    end

    def with_comment_stats
      relation = left_outer_joins(:comments).group(:id).select("posts.*")
      relation = relation.select("COUNT(comments.id) AS comment_count")
      relation = relation.select("COUNT(comments.id) FILTER (WHERE comments.is_deleted = TRUE)  AS deleted_comment_count")
      relation = relation.select("COUNT(comments.id) FILTER (WHERE comments.is_deleted = FALSE) AS active_comment_count")
      relation
    end

    def with_note_stats
      relation = left_outer_joins(:notes).group(:id).select("posts.*")
      relation = relation.select("COUNT(notes.id) AS note_count")
      relation = relation.select("COUNT(notes.id) FILTER (WHERE notes.is_active = TRUE)  AS active_note_count")
      relation = relation.select("COUNT(notes.id) FILTER (WHERE notes.is_active = FALSE) AS deleted_note_count")
      relation
    end

    def with_flag_stats
      relation = left_outer_joins(:flags).group(:id).select("posts.*")
      relation = relation.select("COUNT(post_flags.id) AS flag_count")
      relation = relation.select("COUNT(post_flags.id) FILTER (WHERE post_flags.is_resolved = TRUE)  AS resolved_flag_count")
      relation = relation.select("COUNT(post_flags.id) FILTER (WHERE post_flags.is_resolved = FALSE) AS unresolved_flag_count")
      relation
    end

    def with_appeal_stats
      relation = left_outer_joins(:appeals).group(:id).select("posts.*")
      relation = relation.select("COUNT(post_appeals.id) AS appeal_count")
      relation
    end

    def with_approval_stats
      relation = left_outer_joins(:approvals).group(:id).select("posts.*")
      relation = relation.select("COUNT(post_approvals.id) AS approval_count")
      relation
    end

    def with_replacement_stats
      relation = left_outer_joins(:replacements).group(:id).select("posts.*")
      relation = relation.select("COUNT(post_replacements.id) AS replacement_count")
      relation
    end

    def with_child_stats
      relation = left_outer_joins(:children).group(:id).select("posts.*")
      relation = relation.select("COUNT(children_posts.id) AS child_count")
      relation = relation.select("COUNT(children_posts.id) FILTER (WHERE children_posts.is_deleted = TRUE)  AS deleted_child_count")
      relation = relation.select("COUNT(children_posts.id) FILTER (WHERE children_posts.is_deleted = FALSE) AS active_child_count")
      relation
    end

    def with_pool_stats
      pool_posts = Pool.joins("CROSS JOIN unnest(post_ids) AS post_id").select(:id, :is_deleted, :category, "post_id")
      relation = joins("LEFT OUTER JOIN (#{pool_posts.to_sql}) pools ON pools.post_id = posts.id").group(:id).select("posts.*")

      relation = relation.select("COUNT(pools.id) AS pool_count")
      relation = relation.select("COUNT(pools.id) FILTER (WHERE pools.is_deleted = TRUE) AS deleted_pool_count")
      relation = relation.select("COUNT(pools.id) FILTER (WHERE pools.is_deleted = FALSE) AS active_pool_count")
      relation = relation.select("COUNT(pools.id) FILTER (WHERE pools.category = 'series') AS series_pool_count")
      relation = relation.select("COUNT(pools.id) FILTER (WHERE pools.category = 'collection') AS collection_pool_count")
      relation
    end

    def with_stats(tables)
      return all if tables.empty?

      relation = all
      tables.each do |table|
        relation = relation.send("with_#{table}_stats")
      end

      from(relation.arel.as("posts"))
    end

    def pending
      where(is_pending: true)
    end

    def flagged
      where(is_flagged: true)
    end

    def pending_or_flagged
      pending.or(flagged)
    end

    def undeleted
      where("is_deleted = ?", false)
    end

    def deleted
      where("is_deleted = ?", true)
    end

    def has_notes
      where("last_noted_at is not null")
    end

    def for_user(user_id)
      where("uploader_id = ?", user_id)
    end

    def available_for_moderation(hidden = false, user = CurrentUser.user)
      return none if user.is_anonymous?

      approved_posts = user.post_approvals.select(:post_id)
      disapproved_posts = user.post_disapprovals.select(:post_id)

      if hidden.present?
        where("posts.uploader_id = ? OR posts.id IN (#{approved_posts.to_sql}) OR posts.id IN (#{disapproved_posts.to_sql})", user.id)
      else
        where.not(uploader: user).where.not(id: approved_posts).where.not(id: disapproved_posts)
      end
    end

    def raw_tag_match(tag)
      where("posts.tag_index @@ to_tsquery('danbooru', E?)", tag.to_escaped_for_tsquery)
    end

    def tag_match(query)
      PostQueryBuilder.new(query).build
    end
  end

  module PixivMethods
    def parse_pixiv_id
      self.pixiv_id = nil

      site = Sources::Strategies::Pixiv.new(source)
      if site.match?
        self.pixiv_id = site.illust_id
      end
    end
  end

  module IqdbMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def iqdb_sqs_service
        SqsService.new(Danbooru.config.aws_sqs_iqdb_url)
      end

      def iqdb_enabled?
        Danbooru.config.aws_sqs_iqdb_url.present?
      end

      def remove_iqdb(post_id)
        if iqdb_enabled?
          iqdb_sqs_service.send_message("remove\n#{post_id}")
        end
      end
    end

    def update_iqdb_async
      if Post.iqdb_enabled? && has_preview?
        Post.iqdb_sqs_service.send_message("update\n#{id}\n#{preview_file_url}")
      end
    end

    def remove_iqdb_async
      Post.remove_iqdb(id)
    end
  end

  module ValidationMethods
    def post_is_not_its_own_parent
      if !new_record? && id == parent_id
        errors[:base] << "Post cannot have itself as a parent"
        false
      end
    end

    def updater_can_change_rating
      if rating_changed? && is_rating_locked?
        # Don't forbid changes if the rating lock was just now set in the same update.
        if !is_rating_locked_changed?
          errors.add(:rating, "is locked and cannot be changed. Unlock the post first.")
        end
      end
    end

    def uploader_is_not_limited
      errors[:uploader] << uploader.upload_limit.limit_reason if uploader.upload_limit.limited?
    end

    def added_tags_are_valid
      new_tags = added_tags.select { |t| t.post_count <= 0 }
      new_general_tags = new_tags.select { |t| t.category == Tag.categories.general }
      new_artist_tags = new_tags.select { |t| t.category == Tag.categories.artist }
      repopulated_tags = new_tags.select { |t| (t.category != Tag.categories.general) && (t.category != Tag.categories.meta) && (t.created_at < 1.hour.ago) }

      if new_general_tags.present?
        n = new_general_tags.size
        tag_wiki_links = new_general_tags.map { |tag| "[[#{tag.name}]]" }
        self.warnings[:base] << "Created #{n} new #{(n == 1) ? "tag" : "tags"}: #{tag_wiki_links.join(", ")}"
      end

      if repopulated_tags.present?
        n = repopulated_tags.size
        tag_wiki_links = repopulated_tags.map { |tag| "[[#{tag.name}]]" }
        self.warnings[:base] << "Repopulated #{n} old #{(n == 1) ? "tag" : "tags"}: #{tag_wiki_links.join(", ")}"
      end

      new_artist_tags.each do |tag|
        if tag.artist.blank?
          self.warnings[:base] << "Artist [[#{tag.name}]] requires an artist entry. \"Create new artist entry\":[/artists/new?artist%5Bname%5D=#{CGI.escape(tag.name)}]"
        end
      end
    end

    def removed_tags_are_valid
      attempted_removed_tags = @removed_tags + @negated_tags
      unremoved_tags = tag_array & attempted_removed_tags

      if unremoved_tags.present?
        unremoved_tags_list = unremoved_tags.map { |t| "[[#{t}]]" }.to_sentence
        self.warnings[:base] << "#{unremoved_tags_list} could not be removed. Check for implications and try again"
      end
    end

    def has_artist_tag
      return if !new_record?
      return if source !~ %r!\Ahttps?://!
      return if has_tag?("artist_request") || has_tag?("official_art")
      return if tags.any? { |t| t.category == Tag.categories.artist }
      return if Sources::Strategies.find(source).is_a?(Sources::Strategies::Null)

      self.warnings[:base] << "Artist tag is required. \"Create new artist tag\":[/artists/new?artist%5Bsource%5D=#{CGI.escape(source)}]. Ask on the forum if you need naming help"
    end

    def has_copyright_tag
      return if !new_record?
      return if has_tag?("copyright_request") || tags.any? { |t| t.category == Tag.categories.copyright }

      self.warnings[:base] << "Copyright tag is required. Consider adding [[copyright request]] or [[original]]"
    end

    def has_enough_tags
      return if !new_record?

      if tags.count { |t| t.category == Tag.categories.general } < 10
        self.warnings[:base] << "Uploads must have at least 10 general tags. Read [[howto:tag]] for guidelines on tagging your uploads"
      end
    end
  end

  include FileMethods
  include ImageMethods
  include ApprovalMethods
  include PresenterMethods
  include TagMethods
  include FavoriteMethods
  include UploaderMethods
  include PoolMethods
  include VoteMethods
  extend CountMethods
  include ParentMethods
  include DeletionMethods
  include VersionMethods
  include NoteMethods
  include ApiMethods
  extend SearchMethods
  include PixivMethods
  include IqdbMethods
  include ValidationMethods
  include Danbooru::HasBitFlags

  BOOLEAN_ATTRIBUTES = %w(
    has_embedded_notes
    has_cropped
  )
  has_bit_flags BOOLEAN_ATTRIBUTES

  def safeblocked?
    CurrentUser.safe_mode? && (rating != "s" || Danbooru.config.safe_mode_restricted_tags.any? { |tag| tag.in?(tag_array) })
  end

  def levelblocked?
    !CurrentUser.is_gold? && Danbooru.config.restricted_tags.any? { |tag| tag.in?(tag_array) }
  end

  def banblocked?
    is_banned? && !CurrentUser.is_gold?
  end

  def visible?
    !safeblocked? && !levelblocked? && !banblocked?
  end

  def reload(options = nil)
    super
    reset_tag_array_cache
    @pools = nil
    @tag_categories = nil
    @typed_tags = nil
    self
  end

  def strip_source
    self.source = source.try(:strip)
  end

  def mark_as_translated(params)
    add_tag("check_translation") if params["check_translation"].to_s.truthy?
    remove_tag("check_translation") if params["check_translation"].to_s.falsy?

    add_tag("partially_translated") if params["partially_translated"].to_s.truthy?
    remove_tag("partially_translated") if params["partially_translated"].to_s.falsy?

    if has_tag?("check_translation") || has_tag?("partially_translated")
      add_tag("translation_request")
      remove_tag("translated")
    else
      add_tag("translated")
      remove_tag("translation_request")
    end

    save
  end

  def self.available_includes
    includes_array = [:uploader, :updater, :approver, :parent, :upload, :artist_commentary, :flags, :appeals, :notes, :comments, :children, :approvals, :replacements]
    includes_array << :moderation_reports if CurrentUser.is_moderator?
    includes_array << :disapprovals if CurrentUser.user.is_approver?
    includes_array
  end
end
