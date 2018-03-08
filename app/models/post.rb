require 'danbooru/has_bit_flags'
require 'google/apis/pubsub_v1'

class Post < ApplicationRecord
  class ApprovalError < Exception ; end
  class DisapprovalError < Exception ; end
  class RevertError < Exception ; end
  class SearchError < Exception ; end
  class DeletionError < Exception ; end

  before_validation :initialize_uploader, :on => :create
  before_validation :merge_old_changes
  before_validation :normalize_tags
  before_validation :strip_source
  before_validation :parse_pixiv_id
  before_validation :blank_out_nonexistent_parents
  before_validation :remove_parent_loops
  validates_uniqueness_of :md5, :on => :create
  validates_inclusion_of :rating, in: %w(s q e), message: "rating must be s, q, or e"
  validate :tag_names_are_valid
  validate :added_tags_are_valid
  validate :removed_tags_are_valid
  validate :has_artist_tag
  validate :has_copyright_tag
  validate :has_enough_tags
  validate :post_is_not_its_own_parent
  validate :updater_can_change_rating
  before_save :update_tag_post_counts
  before_save :set_tag_counts
  before_save :set_pool_category_pseudo_tags
  before_create :autoban
  after_save :queue_backup, if: :md5_changed?
  after_save :create_version
  after_save :update_parent_on_save
  after_save :apply_post_metatags
  after_save :expire_essential_tag_string_cache
  after_commit :delete_files, :on => :destroy
  after_commit :remove_iqdb_async, :on => :destroy
  after_commit :update_iqdb_async, :on => :create
  after_commit :notify_pubsub

  belongs_to :updater, :class_name => "User"
  belongs_to :approver, :class_name => "User"
  belongs_to :uploader, :class_name => "User", :counter_cache => "post_upload_count"
  belongs_to :parent, :class_name => "Post"
  has_one :upload, :dependent => :destroy
  has_one :artist_commentary, :dependent => :destroy
  has_one :pixiv_ugoira_frame_data, :class_name => "PixivUgoiraFrameData", :dependent => :destroy
  has_many :flags, :class_name => "PostFlag", :dependent => :destroy
  has_many :appeals, :class_name => "PostAppeal", :dependent => :destroy
  has_many :votes, :class_name => "PostVote", :dependent => :destroy
  has_many :notes, :dependent => :destroy
  has_many :comments, lambda {includes(:creator, :updater).order("comments.id")}, :dependent => :destroy
  has_many :children, lambda {order("posts.id")}, :class_name => "Post", :foreign_key => "parent_id"
  has_many :approvals, :class_name => "PostApproval", :dependent => :destroy
  has_many :disapprovals, :class_name => "PostDisapproval", :dependent => :destroy
  has_many :favorites
  has_many :replacements, class_name: "PostReplacement", :dependent => :destroy

  if PostArchive.enabled?
    has_many :versions, lambda {order("post_versions.updated_at ASC")}, :class_name => "PostArchive", :dependent => :destroy
  end

  attr_accessible :source, :rating, :tag_string, :old_tag_string, :old_parent_id, :old_source, :old_rating, :parent_id, :has_embedded_notes, :as => [:member, :builder, :gold, :platinum, :moderator, :admin, :default]
  attr_accessible :is_rating_locked, :is_note_locked, :has_cropped, :as => [:builder, :moderator, :admin]
  attr_accessible :is_status_locked, :as => [:admin]
  attr_accessor :old_tag_string, :old_parent_id, :old_source, :old_rating, :has_constraints, :disable_versioning, :view_count

  module FileMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def delete_files(post_id, file_path, large_file_path, preview_file_path, force: false)
        unless force
          # XXX should pass in the md5 instead of parsing it.
          preview_file_path =~ %r!/data/preview/(?:test\.)?([a-z0-9]{32})\.jpg\z!
          md5 = $1

          if Post.where(md5: md5).exists?
            raise DeletionError.new("Files still in use; skipping deletion.")
          end
        end

        backup_service = Danbooru.config.backup_service
        backup_service.delete(file_path, type: :original)
        backup_service.delete(large_file_path, type: :large)
        backup_service.delete(preview_file_path, type: :preview)

        # the large file and the preview don't necessarily exist. if so errors will be ignored.
        FileUtils.rm_f(file_path)
        FileUtils.rm_f(large_file_path)
        FileUtils.rm_f(preview_file_path)

        RemoteFileManager.new(file_path).delete
        RemoteFileManager.new(large_file_path).delete
        RemoteFileManager.new(preview_file_path).delete

        if Danbooru.config.cloudflare_key
          md5, ext = File.basename(file_path).split(".")
          CloudflareService.new.delete(md5, ext)
        end
      end
    end

    def delete_files
      Post.delete_files(id, file_path, large_file_path, preview_file_path, force: true)
    end

    def distribute_files
      if Danbooru.config.build_file_url(self) =~ /^http/
        # this post is archived
        RemoteFileManager.new(file_path).distribute_to_archive(Danbooru.config.build_file_url(self))
        RemoteFileManager.new(preview_file_path).distribute if has_preview?
        RemoteFileManager.new(large_file_path).distribute_to_archive(Danbooru.config.build_large_file_url(self)) if has_large?
      else
        RemoteFileManager.new(file_path).distribute
        RemoteFileManager.new(preview_file_path).distribute if has_preview?
        RemoteFileManager.new(large_file_path).distribute if has_large?
      end
    end

    def file_path_prefix
      Rails.env == "test" ? "test." : ""
    end

    def file_path
      "#{Rails.root}/public/data/#{file_path_prefix}#{md5}.#{file_ext}"
    end

    def large_file_path
      if has_large?
        "#{Rails.root}/public/data/sample/#{file_path_prefix}#{Danbooru.config.large_image_prefix}#{md5}.#{large_file_ext}"
      else
        file_path
      end
    end

    def large_file_ext
      if is_ugoira?
        "webm"
      else
        "jpg"
      end
    end

    def preview_file_path
      "#{Rails.root}/public/data/preview/#{file_path_prefix}#{md5}.jpg"
    end

    def file_name
      "#{file_path_prefix}#{md5}.#{file_ext}"
    end

    def file_url
      Danbooru.config.build_file_url(self)
    end

    # this is for the 640x320 version
    def cropped_file_url
    end

    def large_file_url
      if has_large?
        Danbooru.config.build_large_file_url(self)
      else
        file_url
      end
    end

    def seo_tag_string
      if Danbooru.config.enable_seo_post_urls && !CurrentUser.user.disable_tagged_filenames?
        "__#{seo_tags}__"
      else
        nil
      end
    end

    def seo_tags
      @seo_tags ||= humanized_essential_tag_string.gsub(/[^a-z0-9]+/, "_").gsub(/(?:^_+)|(?:_+$)/, "").gsub(/_{2,}/, "_")
    end

    def preview_file_url
      if !has_preview?
        return "/images/download-preview.png"
      end

      "/data/preview/#{file_path_prefix}#{md5}.jpg"
    end

    def complete_preview_file_url
      "http://#{Danbooru.config.hostname}#{preview_file_url}"
    end

    def open_graph_image_url
      if is_image?
        if has_large?
          if Danbooru.config.build_large_file_url(self) =~ /http/
            large_file_url
          else
            "http://#{Danbooru.config.hostname}#{large_file_url}"
          end
        else
          if Danbooru.config.build_file_url(self) =~ /http/
            file_url
          else
            "http://#{Danbooru.config.hostname}#{file_url}"
          end
        end
      else
        complete_preview_file_url
      end
    end

    def file_url_for(user)
      if CurrentUser.mobile_mode?
        large_file_url
      elsif user.default_image_size == "large" && image_width > Danbooru.config.large_image_width
        large_file_url
      else
        file_url
      end
    end

    def file_path_for(user)
      if CurrentUser.mobile_mode?
        large_file_path
      elsif user.default_image_size == "large" && image_width > Danbooru.config.large_image_width
        large_file_path
      else
        file_path
      end
    end

    def is_image?
      file_ext =~ /jpg|jpeg|gif|png/i
    end

    def is_animated_gif?
      if file_ext =~ /gif/i && File.exists?(file_path)
        return Magick::Image.ping(file_path).length > 1
      else
        return false
      end
    end
    
    def is_animated_png?
      if file_ext =~ /png/i && File.exists?(file_path)
        apng = APNGInspector.new(file_path)
        apng.inspect!
        return apng.animated?
      else
        return false
      end
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
      # for video/ugoira we don't want to try and render a preview that
      # might doesn't exist yet
      is_image? || ((is_video? || is_ugoira?) && File.exists?(preview_file_path))
    end

    def has_dimensions?
      image_width.present? && image_height.present?
    end

    def has_ugoira_webm?
      created_at < 1.minute.ago || (File.exists?(preview_file_path) && File.size(preview_file_path) > 0)
    end
  end

  module BackupMethods
    extend ActiveSupport::Concern

    def queue_backup
      Post.delay(queue: "default", priority: -1).backup_file(file_path, id: id, type: :original)
      Post.delay(queue: "default", priority: -1).backup_file(large_file_path, id: id, type: :large) if has_large?
      Post.delay(queue: "default", priority: -1).backup_file(preview_file_path, id: id, type: :preview) if has_preview?
    end

    module ClassMethods
      def backup_file(file_path, options = {})
        backup_service = Danbooru.config.backup_service
        backup_service.backup(file_path, options)
      end
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

    def has_large
      !!has_large?
    end

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
      if CurrentUser.mobile_mode? || user.default_image_size == "large"
        large_image_width
      else
        image_width
      end
    end

    def image_height_for(user)
      if CurrentUser.mobile_mode? || user.default_image_size == "large"
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
      !is_status_locked? && (is_pending? || is_flagged? || is_deleted?) && !approved_by?(user)
    end

    def flag!(reason, options = {})
      flag = flags.create(:reason => reason, :is_resolved => false, :is_deletion => options[:is_deletion])

      if flag.errors.any?
        raise PostFlag::Error.new(flag.errors.full_messages.join("; "))
      end
    end

    def appeal!(reason)
      if is_status_locked?
        raise PostAppeal::Error.new("Post is locked and cannot be appealed")
      end

      appeal = appeals.create(:reason => reason)

      if appeal.errors.any?
        raise PostAppeal::Error.new(appeal.errors.full_messages.join("; "))
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
      case source
      when %r{\Ahttps?://img\d+\.pixiv\.net/img/[^\/]+/(\d+)}i, 
           %r{\Ahttps?://i\d\.pixiv\.net/img\d+/img/[^\/]+/(\d+)}i
        "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{$1}"

      when %r{\Ahttps?://(?:i\d+\.pixiv\.net|i\.pximg\.net)/img-(?:master|original)/img/(?:\d+\/)+(\d+)_p}i,
           %r{\Ahttps?://(?:i\d+\.pixiv\.net|i\.pximg\.net)/c/\d+x\d+/img-master/img/(?:\d+\/)+(\d+)_p}i,
           %r{\Ahttps?://(?:i\d+\.pixiv\.net|i\.pximg\.net)/img-zip-ugoira/img/(?:\d+\/)+(\d+)_ugoira\d+x\d+\.zip}i
        "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{$1}"

      when %r{\Ahttps?://lohas\.nicoseiga\.jp/priv/(\d+)\?e=\d+&h=[a-f0-9]+}i, 
           %r{\Ahttps?://lohas\.nicoseiga\.jp/priv/[a-f0-9]+/\d+/(\d+)}i
        "http://seiga.nicovideo.jp/seiga/im#{$1}"

      when %r{\Ahttps?://(?:d3j5vwomefv46c|dn3pm25xmtlyu)\.cloudfront\.net/photos/large/(\d+)\.}i
        base_10_id = $1.to_i
        base_36_id = base_10_id.to_s(36)
        "http://twitpic.com/#{base_36_id}"

      # http://orig12.deviantart.net/9b69/f/2017/023/7/c/illustration___tokyo_encount_oei__by_melisaongmiqin-dawi58s.png
      # http://pre15.deviantart.net/81de/th/pre/f/2015/063/5/f/inha_by_inhaestudios-d8kfzm5.jpg
      # http://th00.deviantart.net/fs71/PRE/f/2014/065/3/b/goruto_by_xyelkiltrox-d797tit.png
      # http://th04.deviantart.net/fs70/300W/f/2009/364/4/d/Alphes_Mimic___Rika_by_Juriesute.png
      # http://fc02.deviantart.net/fs48/f/2009/186/2/c/Animation_by_epe_tohri.swf
      # http://fc08.deviantart.net/files/f/2007/120/c/9/Cool_Like_Me_by_47ness.jpg
      # http://fc08.deviantart.net/images3/i/2004/088/8/f/Blackrose_for_MuzicFreq.jpg
      # http://img04.deviantart.net/720b/i/2003/37/9/6/princess_peach.jpg
      when %r{\Ahttps?://(?:fc|th|pre|orig|img|prnt)\d{2}\.deviantart\.net/.+/(?<title>[a-z0-9_]+)_by_(?<artist>[a-z0-9_]+)-d(?<id>[a-z0-9]+)\.}i
        artist = $~[:artist].dasherize
        title = $~[:title].titleize.strip.squeeze(" ").tr(" ", "-")
        id = $~[:id].to_i(36)
        "http://#{artist}.deviantart.com/art/#{title}-#{id}"

      # http://prnt00.deviantart.net/9b74/b/2016/101/4/468a9d89f52a835d4f6f1c8caca0dfb2-pnjfbh.jpg
      # http://fc00.deviantart.net/fs71/f/2013/234/d/8/d84e05f26f0695b1153e9dab3a962f16-d6j8jl9.jpg
      # http://th04.deviantart.net/fs71/PRE/f/2013/337/3/5/35081351f62b432f84eaeddeb4693caf-d6wlrqs.jpg
      # http://fc09.deviantart.net/fs22/o/2009/197/3/7/37ac79eaeef9fb32e6ae998e9a77d8dd.jpg
      when %r{\Ahttps?://(?:fc|th|pre|orig|img|prnt)\d{2}\.deviantart\.net/.+/[a-f0-9]{32}-d(?<id>[a-z0-9]+)\.}i
        id = $~[:id].to_i(36)
        "http://deviantart.com/deviation/#{id}"

      when %r{\Ahttp://www\.karabako\.net/images(?:ub)?/karabako_(\d+)(?:_\d+)?\.}i
        "http://www.karabako.net/post/view/#{$1}"

      when %r{\Ahttp://p\.twpl\.jp/show/orig/([a-z0-9]+)}i
        "http://p.twipple.jp/#{$1}"

      when %r{\Ahttps?://pictures\.hentai-foundry\.com//?[^/]/([^/]+)/(\d+)}i
        "http://www.hentai-foundry.com/pictures/user/#{$1}/#{$2}"

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
        "http://chan.sankakucomplex.com/en/post/show?md5=#{$1}"

      when %r{\Ahttp://s(?:tatic|[1-4])\.zerochan\.net/.+(?:\.|\/)(\d+)\.(?:jpe?g?)\z}i
        "http://www.zerochan.net/#{$1}#full"

      when %r{\Ahttp://static[1-6]?\.minitokyo\.net/(?:downloads|view)/(?:\d{2}/){2}(\d+)}i
        "http://gallery.minitokyo.net/download/#{$1}"

      when %r{\Ahttp://(?:(?:s?img|cdn|www)\d?\.)?gelbooru\.com/{1,2}(?:images|samples)/\d+/(?:sample_)?(?:[a-f0-9]{32}|[a-f0-9]{40})\.}i
        "http://gelbooru.com/index.php?page=post&s=list&md5=#{md5}"

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
        "http://rule34.paheal.net/post/list/md5:#{$1}/1"
        
      when %r{\Ahttp://shimmie\.katawa-shoujo\.com/image/(\d+)}i
        "http://shimmie.katawa-shoujo.com/post/view/#{$1}"
        
      when %r{\Ahttp://(?:(?:(?:img\d?|cdn)\.)?rule34\.xxx|img\.booru\.org/(?:rule34|r34))(?:/(?:img/rule34|r34))?/{1,2}images/\d+/(?:[a-f0-9]{32}|[a-f0-9]{40})\.}i
        "http://rule34.xxx/index.php?page=post&s=list&md5=#{md5}"
        
      when %r{\Ahttps?://(?:s3\.amazonaws\.com/imgly_production|img\.ly/system/uploads)/((?:\d{3}/){3}|\d+/)}i
        imgly_id = $1
        imgly_id = imgly_id.gsub(/[^0-9]/, '')
        base_62 = imgly_id.to_i.encode62
        "http://img.ly/#{base_62}"
        
      when %r{(\Ahttp://.+)/diarypro/d(?:ata/upfile/|iary\.cgi\?mode=image&upfile=)(\d+)}i
        base_url = $1
        entry_no = $2
        "#{base_url}/diarypro/diary.cgi?no=#{entry_no}"
        
      when %r{\Ahttp://i(?:\d)?\.minus\.com/(?:i|j)([^\.]{12,})}i
        "http://minus.com/i/#{$1}"
        
      when %r{\Ahttps?://pic0[1-4]\.nijie\.info/nijie_picture/(?:diff/main/)?\d+_(\d+)_(?:\d+{10}|\d+_\d+{14})}i
        "http://nijie.info/view.php?id=#{$1}"

      # http://ayase.yande.re/image/2d0d229fd8465a325ee7686fcc7f75d2/yande.re%20192481%20animal_ears%20bunny_ears%20garter_belt%20headphones%20mitha%20stockings%20thighhighs.jpg
      # https://yuno.yande.re/image/1764b95ae99e1562854791c232e3444b/yande.re%20281544%20cameltoe%20erect_nipples%20fundoshi%20horns%20loli%20miyama-zero%20sarashi%20sling_bikini%20swimsuits.jpg
      # https://files.yande.re/image/2a5d1d688f565cb08a69ecf4e35017ab/yande.re%20349790%20breast_hold%20kurashima_tomoyasu%20mahouka_koukou_no_rettousei%20naked%20nipples.jpg
      # https://files.yande.re/sample/0d79447ce2c89138146f64ba93633568/yande.re%20290757%20sample%20seifuku%20thighhighs%20tsukudani_norio.jpg
      when %r{\Ahttps?://(?:ayase\.|yuno\.|files\.)?yande\.re/(?:sample|image)/[a-z0-9]{32}/yande\.re%20(?<post_id>[0-9]+)%20}i
        "https://yande.re/post/show/#{$~[:post_id]}"

      # https://yande.re/jpeg/0c9ec0ffcaa40470093cb44c3fd40056/yande.re%2064649%20animal_ears%20cameltoe%20fixme%20nekomimi%20nipples%20ryohka%20school_swimsuit%20see_through%20shiraishi_nagomi%20suzuya%20swimsuits%20tail%20thighhighs.jpg
      # https://yande.re/jpeg/22577d2344fe694cf47f80563031b3cd.jpg
      # https://yande.re/image/b4b1d11facd1700544554e4805d47bb6/.png
      # https://yande.re/sample/ceb6a12e87945413a95b90fada406f91/.jpg
      when %r{\Ahttps?://(?:ayase\.|yuno\.|files\.)?yande\.re/(?:image|jpeg|sample)/(?<md5>[a-z0-9]{32})(?:/yande\.re.*|/?\.(?:jpg|png))\Z}i
        "https://yande.re/post?tags=md5:#{$~[:md5]}"

      # https://gfee_li.artstation.com/projects/XPGOD
      # https://gfee_li.artstation.com/projects/asuka-7
      when %r{\Ahttps?://\w+\.artstation.com/(?:artwork|projects)/(?<project_id>[a-z0-9-]+)\z/}i
        "https://www.artstation.com/artwork/#{$~[:project_id]}"
        
      when %r{\Ahttps?://(?:o|image-proxy-origin)\.twimg\.com/\d/proxy\.jpg\?t=(\w+)&}i
        str = Base64.decode64($1)
        url = URI.extract(str, ['http', 'https'])
        if url.any?
          url = url[0]
          if (url =~ /^https?:\/\/twitpic.com\/show\/large\/[a-z0-9]+/i)
            url.gsub!(/show\/large\//, "")
            index = url.rindex('.')
            url = url[0..index-1]
          end
          url
        else
          source
        end

      else
        source
      end
    end
  end

  module TagMethods
    def tag_array
      @tag_array ||= Tag.scan_tags(tag_string)
    end

    def tag_array_was
      @tag_array_was ||= Tag.scan_tags(tag_string_was)
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
      if decrement_tags_except_requests.size > 0 && !CurrentUser.is_builder? && CurrentUser.created_at > 1.week.ago
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

    def set_tag_count(category,tagcount)
      self.send("tag_count_#{category}=",tagcount)
    end

    def inc_tag_count(category)
      set_tag_count(category,self.send("tag_count_#{category}") + 1)
    end

    def set_tag_counts(disable_cache = true)
      self.tag_count = 0
      TagCategory.categories.each {|x| set_tag_count(x,0)}
      categories = Tag.categories_for(tag_array, :disable_caching => disable_cache)
      categories.each_value do |category|
        self.tag_count += 1
        inc_tag_count(TagCategory.reverse_mapping[category])
      end
    end

    def merge_old_changes
      @removed_tags = []

      if old_tag_string
        # If someone else committed changes to this post before we did,
        # then try to merge the tag changes together.
        current_tags = tag_array_was()
        new_tags = tag_array()
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
        self.parent_id = parent_id_was
      end

      if old_source == source.to_s
        self.source = source_was
      end

      if old_rating == rating
        self.rating = rating_was
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
      normalized_tags = normalized_tags.map {|tag| tag.downcase}
      normalized_tags = filter_metatags(normalized_tags)
      normalized_tags = remove_negated_tags(normalized_tags)
      normalized_tags = TagAlias.to_aliased(normalized_tags)
      normalized_tags = %w(tagme) if normalized_tags.empty?
      normalized_tags = add_automatic_tags(normalized_tags)
      normalized_tags = remove_invalid_tags(normalized_tags)
      normalized_tags = Tag.convert_cosplay_tags(normalized_tags)
      normalized_tags = normalized_tags + Tag.create_for_list(TagImplication.automatic_tags_for(normalized_tags))
      normalized_tags = TagImplication.with_descendants(normalized_tags)
      normalized_tags = normalized_tags.compact.uniq.sort
      normalized_tags = Tag.create_for_list(normalized_tags)
      set_tag_string(normalized_tags.join(" "))
    end

    def remove_invalid_tags(tags)
      invalid_tags = Tag.invalid_cosplay_tags(tags)
      if invalid_tags.present?
        self.warnings[:base] << "The root tag must be a character tag: #{invalid_tags.map {|tag| "[b]#{tag}[/b]" }.join(", ")}"
      end
      tags - invalid_tags
    end

    def remove_negated_tags(tags)
      @negated_tags, tags = tags.partition {|x| x =~ /\A-/i}
      @negated_tags = @negated_tags.map {|x| x[1..-1]}
      @negated_tags = TagAlias.to_aliased(@negated_tags)
      return tags - @negated_tags
    end

    def add_automatic_tags(tags)
      return tags if !Danbooru.config.enable_dimension_autotagging

      tags -= %w(incredibly_absurdres absurdres highres lowres huge_filesize flash webm mp4)
      tags -= %w(animated_gif animated_png) if new_record?

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

      if is_animated_gif?
        tags << "animated_gif"
      end
      
      if is_animated_png?
        tags << "animated_png"
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

      return tags
    end

    def apply_casesensitive_metatags(tags)
      casesensitive_metatags, tags = tags.partition {|x| x =~ /\A(?:source):/i}
      #Reuse the following metatags after the post has been saved
      casesensitive_metatags += tags.select {|x| x =~ /\A(?:newpool):/i}
      if casesensitive_metatags.length > 0
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
            pool = Pool.create(:name => $1, :description => "This pool was automatically generated")
          end
        end
      end
      return tags
    end

    def filter_metatags(tags)
      @pre_metatags, tags = tags.partition {|x| x =~ /\A(?:rating|parent|-parent|-?locked):/i}
      tags = apply_categorization_metatags(tags)
      @post_metatags, tags = tags.partition {|x| x =~ /\A(?:-pool|pool|newpool|fav|-fav|child|-favgroup|favgroup|upvote|downvote):/i}
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

        when /^child:(.+)$/i
          child = Post.find($1)
          child.parent_id = id
          child.save

        when /^-favgroup:(\d+)$/i
          favgroup = FavoriteGroup.where("id = ?", $1.to_i).for_creator(CurrentUser.user.id).first
          favgroup.remove!(id) if favgroup

        when /^-favgroup:(.+)$/i
          favgroup = FavoriteGroup.named($1).for_creator(CurrentUser.user.id).first
          favgroup.remove!(id) if favgroup

        when /^favgroup:(\d+)$/i
          favgroup = FavoriteGroup.where("id = ?", $1.to_i).for_creator(CurrentUser.user.id).first
          favgroup.add!(id) if favgroup

        when /^favgroup:(.+)$/i
          favgroup = FavoriteGroup.named($1).for_creator(CurrentUser.user.id).first
          favgroup.add!(id) if favgroup

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
          assign_attributes({ is_note_locked: $1 != "-" }, as: CurrentUser.role)

        when /^(-?)locked:rating$/i
          assign_attributes({ is_rating_locked: $1 != "-" }, as: CurrentUser.role)

        when /^(-?)locked:status$/i
          assign_attributes({ is_status_locked: $1 != "-" }, as: CurrentUser.role)

        end
      end
    end

    def has_tag?(tag)
      !!(tag_string =~ /(?:^| )(?:#{tag})(?:$| )/)
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

    def expire_essential_tag_string_cache
      Cache.delete("hets-#{id}")
    end

    def humanized_essential_tag_string
      @humanized_essential_tag_string ||= Cache.get("hets-#{id}", 1.hour.to_i) do
        string = []

        TagCategory.humanized_list.each do |category|
          typetags = typed_tags(category) - TagCategory.humanized_mapping[category]["exclusion"]
          if TagCategory.humanized_mapping[category]["slice"] > 0
            typetags = typetags.slice(0,TagCategory.humanized_mapping[category]["slice"]) + (typetags.length > TagCategory.humanized_mapping[category]["slice"] ? ["others"] : [])
          end
          if TagCategory.humanized_mapping[category]["regexmap"] != //
            typetags = typetags.map do |tag|
              tag.match(TagCategory.humanized_mapping[category]["regexmap"])[1]
            end
          end
          if typetags.any?
            if category != "copyright" || typed_tags("character").any?
              string << TagCategory.humanized_mapping[category]["formatstr"] % typetags.to_sentence
            else
              string << typetags.to_sentence
            end
          end
        end
        string.empty? ? "##{id}" : string.join(" ").tr("_", " ")
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
      array = fav_string.scan(/\S+/).uniq
      self.fav_string = array.join(" ")
      self.fav_count = array.size
      update_column(:fav_string, fav_string)
      update_column(:fav_count, fav_count)
    end

    def favorited_by?(user_id)
      !!(fav_string =~ /(?:\A| )fav:#{user_id}(?:\Z| )/)
    end

    def append_user_to_fav_string(user_id)
      update_column(:fav_string, (fav_string + " fav:#{user_id}").strip)
      clean_fav_string! if clean_fav_string?
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

    def favorite_groups(active_id=nil)
      @favorite_groups ||= begin
        groups = []

        if active_id.present?
          active_group = FavoriteGroup.where(:id => active_id.to_i).first
          groups << active_group if active_group && active_group.contains?(self.id)
        end

        groups += CurrentUser.user.favorite_groups.select do |favgroup|
          favgroup.contains?(self.id)
        end

        groups.uniq
      end
    end

    def remove_from_favorites
      Favorite.delete_all(post_id: id)
      user_ids = fav_string.scan(/\d+/)
      User.where(:id => user_ids).update_all("favorite_count = favorite_count - 1")
      PostVote.where(post_id: id).delete_all
    end

    def remove_from_fav_groups
      FavoriteGroup.delay.purge_post(id)
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
      User.id_to_name(uploader_id)
    end
  end

  module PoolMethods
    def pools
      @pools ||= begin
        return Pool.none if pool_string.blank?
        pool_ids = pool_string.scan(/\d+/)
        Pool.where(id: pool_ids).series_first
      end
    end

    def has_active_pools?
      pools.undeleted.length > 0
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
        set_pool_category_pseudo_tags
        update_column(:pool_string, pool_string) unless new_record?
        pool.add!(self)
      end
    end

    def remove_pool!(pool)
      return unless belongs_to_pool?(pool)
      return unless CurrentUser.user.can_remove_from_pools?

      with_lock do
        self.pool_string = pool_string.gsub(/(?:\A| )pool:#{pool.id}(?:\Z| )/, " ").strip
        set_pool_category_pseudo_tags
        update_column(:pool_string, pool_string) unless new_record?
        pool.remove!(self)
      end
    end

    def remove_from_all_pools
      pools.find_each do |pool|
        pool.remove!(self)
      end
    end

    def set_pool_category_pseudo_tags
      self.pool_string = (pool_string.scan(/\S+/) - ["pool:series", "pool:collection"]).join(" ")

      pool_categories = pools.undeleted.pluck(:category)
      if pool_categories.include?("series")
        self.pool_string = "#{pool_string} pool:series".strip
      end
      if pool_categories.include?("collection")
        self.pool_string = "#{pool_string} pool:collection".strip
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
    def fast_count(tags = "", options = {})
      tags = tags.to_s
      tags += " rating:s" if CurrentUser.safe_mode?
      tags += " -status:deleted" if CurrentUser.hide_deleted_posts? && tags !~ /(?:^|\s)(?:-)?status:.+/
      tags = Tag.normalize_query(tags)

      # optimize some cases. these are just estimates but at these
      # quantities being off by a few hundred doesn't matter much
      if Danbooru.config.estimate_post_counts
        if tags == ""
          return (Post.maximum(:id) * (2200402.0 / 2232212)).floor

        elsif tags =~ /^rating:s(?:afe)?$/
          return (Post.maximum(:id) * (1648652.0 / 2200402)).floor

        elsif tags =~ /^rating:q(?:uestionable)?$/
          return (Post.maximum(:id) * (350101.0 / 2200402)).floor

        elsif tags =~ /^rating:e(?:xplicit)?$/
          return (Post.maximum(:id) * (201650.0 / 2200402)).floor

        elsif tags =~ /status:deleted.status:deleted/
          # temp fix for degenerate crawlers
          return 0
        end
      end

      count = get_count_from_cache(tags)

      if count.nil?
        count = fast_count_search(tags, options)
      end

      count
    rescue SearchError
      0
    end

    def fast_count_search(tags, options = {})
      count = PostReadOnly.with_timeout(3_000, nil, {:tags => tags}) do
        PostReadOnly.tag_match(tags).count
      end

      if count.nil?
        count = fast_count_search_batched(tags, options)
      end

      if count.nil?
        # give up
        count = Danbooru.config.blank_tag_search_fast_count
      else
        set_count_in_cache(tags, count)
      end

      count ? count.to_i : nil
    rescue PG::ConnectionBad
      return nil
    end

    def fast_count_search_batched(tags, options)
      # this is slower but less likely to timeout
      i = Post.maximum(:id)
      sum = 0
      while i > 0
        count = PostReadOnly.with_timeout(1_000, nil, {:tags => tags}) do
          sum += PostReadOnly.tag_match(tags).where("id <= ? and id > ?", i, i - 25_000).count
          i -= 25_000
        end

        if count.nil?
          return nil
        end
      end
      sum

    rescue PG::ConnectionBad
      return nil
    end

    def fix_post_counts(post)
      post.set_tag_counts(false)
      if post.changed?
        args = Hash[TagCategory.categories.map {|x| ["tag_count_#{x}",post.send("tag_count_#{x}")]}].update(:tag_count => post.tag_count)
        post.update_columns(args)
      end
    end

    def get_count_from_cache(tags)
      if Tag.is_simple_tag?(tags)
        count = select_value_sql("SELECT post_count FROM tags WHERE name = ?", tags.to_s)
      else
        # this will only have a value for multi-tag searches or single metatag searches
        count = Cache.get(count_cache_key(tags))
      end

      count.try(:to_i)
    end

    def set_count_in_cache(tags, count, expiry = nil)
      if expiry.nil?
        [count.seconds, 20.hours].min
      end

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
      update({has_children: children.exists?, has_active_children: children.undeleted.exists?}, without_protection: true)
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
      parent.update_has_children_flag if parent
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
      return unless parent_id_changed? || is_deleted_changed?

      parent.update_has_children_flag if parent.present?
      Post.find(parent_id_was).update_has_children_flag if parent_id_was.present?
    end

    def give_favorites_to_parent(options = {})
      return if parent.nil?

      transaction do
        favorites.each do |fav|
          remove_favorite!(fav.user)
          parent.add_favorite!(fav.user)
        end
      end

      unless options[:without_mod_action]
        ModAction.log("moved favorites from post ##{id} to post ##{parent.id}",:post_move_favorites)
      end
    end

    def parent_exists?
      Post.exists?(parent_id)
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
        children.map{|p| p.id}.join(' ')
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
          ModAction.log("permanently deleted post ##{id}",:post_permanent_delete)

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
      ModAction.log("banned post ##{id}",:post_ban)
    end

    def unban!
      update_column(:is_banned, false)
      ModAction.log("unbanned post ##{id}",:post_unban)
    end

    def delete!(reason, options = {})
      if is_status_locked?
        self.errors.add(:is_status_locked, "; cannot delete post")
        return false
      end

      Post.transaction do
        flag!(reason, is_deletion: true)

        update({
          is_deleted: true,
          is_pending: false,
          is_flagged: false,
          is_banned: is_banned || options[:ban] || has_tag?("banned_artist")
        }, without_protection: true)

        # XXX This must happen *after* the `is_deleted` flag is set to true (issue #3419).
        give_favorites_to_parent(options) if options[:move_favorites]

        unless options[:without_mod_action]
          ModAction.log("deleted post ##{id}, reason: #{reason}",:post_delete)
        end
      end
    end

    def undelete!
      if is_status_locked?
        self.errors.add(:is_status_locked, "; cannot undelete post")
        return false
      end

      if !CurrentUser.is_admin? 
        if approved_by?(CurrentUser.user)
          raise ApprovalError.new("You have previously approved this post and cannot undelete it")
        elsif uploader_id == CurrentUser.id
          raise ApprovalError.new("You cannot undelete a post you uploaded")
        end
      end

      self.is_deleted = false
      self.approver_id = CurrentUser.id
      flags.each {|x| x.resolve!}
      save
      ModAction.log("undeleted post ##{id}",:post_undelete)
    end

    def replace!(params)
      transaction do
        replacement = replacements.create(params)
        replacement.process!
        replacement
      end
    end
  end

  module VersionMethods
    def create_version(force = false)
      if new_record? || rating_changed? || source_changed? || parent_id_changed? || tag_string_changed? || force
        create_new_version
      end
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

    def notify_pubsub
      return unless Danbooru.config.google_api_project

      # PostUpdate.insert(id)
    end
  end

  module NoteMethods
    def has_notes?
      last_noted_at.present?
    end

    def copy_notes_to(other_post)
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
    end
  end

  module ApiMethods
    def hidden_attributes
      list = super + [:tag_index]
      if !visible?
        list += [:md5, :file_ext]
      end
      super + list
    end

    def method_attributes
      list = super + [:uploader_name, :has_large, :has_visible_children, :children_ids] + TagCategory.categories.map {|x| "tag_string_#{x}".to_sym}
      if visible?
        list += [:file_url, :large_file_url, :preview_file_url]
      end
      list
    end

    def associated_attributes
      [ :pixiv_ugoira_frame_data ]
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
        "author" => uploader_name,
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

    def pending
      where("is_pending = ?", true)
    end

    def flagged
      where("is_flagged = ?", true)
    end

    def pending_or_flagged
      where("(is_pending = ? or (is_flagged = ? and id in (select _.post_id from post_flags _ where _.created_at >= ?)))", true, true, 1.week.ago)
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

    def available_for_moderation(hidden, user = CurrentUser.user)
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

    def tag_match(query, read_only = false)
      if query =~ /status:deleted.status:deleted/
        # temp fix for degenerate crawlers
        raise ActiveRecord::RecordNotFound
      end

      if read_only
        begin
          PostQueryBuilder.new(query).build(PostReadOnly.where("true"))
        rescue PG::ConnectionBad
          PostQueryBuilder.new(query).build
        end
      else
        PostQueryBuilder.new(query).build
      end
    end
  end
  
  module PixivMethods
    def parse_pixiv_id
      self.pixiv_id = Sources::Strategies::Pixiv.new(source).illust_id_from_url
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
      if File.exists?(preview_file_path) && Post.iqdb_enabled?
        Post.iqdb_sqs_service.send_message("update\n#{id}\n#{complete_preview_file_url}")
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

    def tag_names_are_valid
      # only validate new tags; allow invalid names for tags that already exist.
      added_tags = tag_array - tag_array_was
      new_tags = added_tags - Tag.where(name: added_tags).pluck(:name)

      new_tags.each do |name|
        tag = Tag.new
        tag.name = name
        tag.valid?

        tag.errors.messages.each do |attribute, messages|
          errors[:tag_string] << "tag #{attribute} #{messages.join(';')}"
        end
      end
    end

    def added_tags_are_valid
      new_tags = added_tags.select { |t| t.post_count <= 0 }
      new_general_tags = new_tags.select { |t| t.category == Tag.categories.general }
      new_artist_tags = new_tags.select { |t| t.category == Tag.categories.artist }
      repopulated_tags = new_tags.select { |t| (t.category != Tag.categories.general) && (t.category != Tag.categories.meta) && (t.created_at < 1.hour.ago) }

      if new_general_tags.present?
        n = new_general_tags.size
        tag_wiki_links = new_general_tags.map { |tag| "[[#{tag.name}]]" }
        self.warnings[:base] << "Created #{n} new #{n == 1 ? "tag" : "tags"}: #{tag_wiki_links.join(", ")}"
      end

      if repopulated_tags.present?
        n = repopulated_tags.size
        tag_wiki_links = repopulated_tags.map { |tag| "[[#{tag.name}]]" }
        self.warnings[:base] << "Repopulated #{n} old #{n == 1 ? "tag" : "tags"}: #{tag_wiki_links.join(", ")}"
      end

      new_artist_tags.each do |tag|
        if tag.artist.blank?
          self.warnings[:base] << "Artist [[#{tag.name}]] requires an artist entry. \"Create new artist entry\":[/artists/new?name=#{CGI::escape(tag.name)}]"
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

      site = Sources::Site.new(source)
      self.warnings[:base] << "Artist tag is required. Create a new tag with [[artist:<artist_name>]]. Ask on the forum if you need naming help"
    rescue Sources::Site::NoStrategyError => e
      # unrecognized source; do nothing.
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
  include BackupMethods
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
    CurrentUser.safe_mode? && (rating != "s" || has_tag?("toddlercon|toddler|diaper|tentacle|rape|bestiality|beastiality|lolita|loli|nude|shota|pussy|penis"))
  end

  def levelblocked?
    !Danbooru.config.can_user_see_post?(CurrentUser.user, self)
  end

  def banblocked?
    is_banned? && !CurrentUser.is_gold?
  end

  def visible?
    return false if safeblocked?
    return false if levelblocked?
    return false if banblocked?
    return true
  end

  def reload(options = nil)
    super
    reset_tag_array_cache
    @pools = nil
    @favorite_groups = nil
    @tag_categories = nil
    @typed_tags = nil
    self
  end

  def strip_source
    self.source = source.try(:strip)
  end

  def mark_as_translated(params)
    tags = self.tag_array.dup

    if params["check_translation"] == "1"
      tags << "check_translation"
    elsif params["check_translation"] == "0"
      tags -= ["check_translation"]
    end
    if params["partially_translated"] == "1"
      tags << "partially_translated"
    elsif params["partially_translated"] == "0"
      tags -= ["partially_translated"]
    end

    if params["check_translation"] == "1" || params["partially_translated"] == "1"
      tags << "translation_request"
      tags -= ["translated"]
    else
      tags << "translated"
      tags -= ["translation_request"]
    end

    self.tag_string = tags.join(" ")
    save
  end

  def update_column(name, value)
    ret = super(name, value)
    notify_pubsub
    ret
  end

  def update_columns(attributes)
    ret = super(attributes)
    notify_pubsub
    ret
  end
end
