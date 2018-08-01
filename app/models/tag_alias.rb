class TagAlias < TagRelationship
  before_save :ensure_tags_exist
  after_save :clear_all_cache
  after_destroy :clear_all_cache
  after_save :clear_all_cache, if: ->(rec) {rec.is_retired?}
  after_save :create_mod_action
  validates_uniqueness_of :antecedent_name
  validate :absence_of_transitive_relation
  validate :antecedent_and_consequent_are_different
  validate :consequent_has_wiki_page, :on => :create
  validate :mininum_antecedent_count, :on => :create

  module CacheMethods
    extend ActiveSupport::Concern

    module ClassMethods
      def clear_cache_for(name)
        Cache.delete("ta:#{Cache.hash(name)}")
      end
    end

    def clear_all_cache
      TagAlias.clear_cache_for(antecedent_name)
      TagAlias.clear_cache_for(consequent_name)
      
      Danbooru.config.other_server_hosts.each do |host|
        TagAlias.delay(:queue => host).clear_cache_for(antecedent_name)
        TagAlias.delay(:queue => host).clear_cache_for(consequent_name)
      end
    end
  end

  module ApprovalMethods
    def approve!(update_topic: true, approver: CurrentUser.user)
      CurrentUser.scoped(approver) do
        update(status: "queued", approver_id: approver.id)
        delay(:queue => "default").process!(update_topic: update_topic)
      end
    end
  end

  module ForumMethods
    def forum_updater
      @forum_updater ||= begin
        post = if forum_topic
          forum_post || forum_topic.posts.where("body like ?", TagAliasRequest.command_string(antecedent_name, consequent_name) + "%").last
        else
          nil
        end
        ForumUpdater.new(
          forum_topic, 
          forum_post: post,
          expected_title: TagAliasRequest.topic_title(antecedent_name, consequent_name)
        )
      end
    end
  end

  include CacheMethods
  include ApprovalMethods
  include ForumMethods

  def self.to_aliased(names)
    Cache.get_multi(Array(names), "ta") do |tag|
      ActiveRecord::Base.select_value_sql("select consequent_name from tag_aliases where status in ('active', 'processing') and antecedent_name = ?", tag) || tag.to_s
    end.values
  end

  def process!(update_topic: true)
    unless valid?
      raise errors.full_messages.join("; ")
    end

    tries = 0

    begin
      CurrentUser.scoped(approver) do
        update(status: "processing")
        move_aliases_and_implications
        move_saved_searches
        clear_all_cache
        ensure_category_consistency
        update_posts
        forum_updater.update(approval_message(approver), "APPROVED") if update_topic
        rename_wiki_and_artist
        update(status: "active", post_count: consequent_tag.post_count)
      end
    rescue Exception => e
      if tries < 5
        tries += 1
        sleep 2 ** tries
        retry
      end

      CurrentUser.scoped(approver) do
        forum_updater.update(failure_message(e), "FAILED") if update_topic
        update(status: "error: #{e}")
      end

      if Rails.env.production?
        NewRelic::Agent.notice_error(e, :custom_params => {:tag_alias_id => id, :antecedent_name => antecedent_name, :consequent_name => consequent_name})
      end
    end
  end

  def absence_of_transitive_relation
    # We don't want a -> b && b -> c chains if the b -> c alias was created first.
    # If the a -> b alias was created first, the new one will be allowed and the old one will be moved automatically instead.
    if self.class.active.exists?(["antecedent_name = ?", consequent_name])
      self.errors[:base] << "A tag alias for #{consequent_name} already exists"
      false
    end
  end

  def antecedent_and_consequent_are_different
    normalize_names
    if antecedent_name == consequent_name
      self.errors[:base] << "Cannot alias a tag to itself"
      false
    end
  end

  def move_saved_searches
    escaped = Regexp.escape(antecedent_name)

    if SavedSearch.enabled?
      SavedSearch.where("query like ?", "%#{antecedent_name}%").find_each do |ss|
        ss.query = ss.query.sub(/(?:^| )#{escaped}(?:$| )/, " #{consequent_name} ").strip.gsub(/  /, " ")
        ss.save
      end
    end
  end

  def move_aliases_and_implications
    aliases = TagAlias.where(["consequent_name = ?", antecedent_name])
    aliases.each do |ta|
      ta.consequent_name = self.consequent_name
      success = ta.save
      if !success && ta.errors.full_messages.join("; ") =~ /Cannot alias a tag to itself/
        ta.destroy
      end
    end

    implications = TagImplication.where(["antecedent_name = ?", antecedent_name])
    implications.each do |ti|
      ti.antecedent_name = self.consequent_name
      success = ti.save
      if !success && ti.errors.full_messages.join("; ") =~ /Cannot implicate a tag to itself/
        ti.destroy
      end
    end

    implications = TagImplication.where(["consequent_name = ?", antecedent_name])
    implications.each do |ti|
      ti.consequent_name = self.consequent_name
      success = ti.save
      if !success && ti.errors.full_messages.join("; ") =~ /Cannot implicate a tag to itself/
        ti.destroy
      end
    end
  end

  def ensure_tags_exist
    Tag.find_or_create_by_name(antecedent_name)
    Tag.find_or_create_by_name(consequent_name)
  end

  def ensure_category_consistency
    if antecedent_tag.category != consequent_tag.category && antecedent_tag.category != Tag.categories.general
      consequent_tag.update_attribute(:category, antecedent_tag.category)
    end

    true
  end

  def update_posts
    Post.without_timeout do
      Post.raw_tag_match(antecedent_name).find_each do |post|
        escaped_antecedent_name = Regexp.escape(antecedent_name)
        fixed_tags = post.tag_string.sub(/(?:\A| )#{escaped_antecedent_name}(?:\Z| )/, " #{consequent_name} ").strip
        CurrentUser.scoped(creator, creator_ip_addr) do
          post.update_attributes(
            :tag_string => fixed_tags
          )
        end
      end

      antecedent_tag.fix_post_count if antecedent_tag
      consequent_tag.fix_post_count if consequent_tag
    end
  end

  def rename_wiki_and_artist
    antecedent_wiki = WikiPage.titled(antecedent_name).first
    if antecedent_wiki.present? 
      if WikiPage.titled(consequent_name).blank?
        CurrentUser.scoped(creator, creator_ip_addr) do
          antecedent_wiki.update(title: consequent_name, skip_secondary_validations: true)
        end
      else
        forum_updater.update(conflict_message)
      end
    end

    if antecedent_tag.category == Tag.categories.artist
      antecedent_artist = Artist.name_matches(antecedent_name).first
      if antecedent_artist.present? && Artist.name_matches(consequent_name).blank?
        CurrentUser.scoped(creator, creator_ip_addr) do
          antecedent_artist.update_attributes(
            :name => consequent_name
          )
        end
      end
    end
  end

  def reject!
    update(status: "deleted")
    clear_all_cache
    forum_updater.update(reject_message(CurrentUser.user), "REJECTED")
    destroy
  end

  def consequent_has_wiki_page
    return if skip_secondary_validations

    unless WikiPage.titled(consequent_name).exists?
      self.errors[:base] << "The #{consequent_name} tag needs a corresponding wiki page"
      return false
    end
  end

  def mininum_antecedent_count
    return if skip_secondary_validations

    unless Post.fast_count(antecedent_name) >= 50
      self.errors[:base] << "The #{antecedent_name} tag must have at least 50 posts for an alias to be created"
    end
  end

  def self.update_cached_post_counts_for_all
    TagAlias.without_timeout do
      execute_sql("UPDATE tag_aliases SET post_count = tags.post_count FROM tags WHERE tags.name = tag_aliases.consequent_name")
    end
  end

  def create_mod_action
    alias_desc = %Q("tag alias ##{id}":[#{Rails.application.routes.url_helpers.tag_alias_path(self)}]: [[#{antecedent_name}]] -> [[#{consequent_name}]])

    if saved_change_to_id?
      ModAction.log("created #{status} #{alias_desc}",:tag_alias_create)
    else
      # format the changes hash more nicely.
      change_desc = saved_changes.except(:updated_at).map do |attribute, values|
        old, new = values[0], values[1]
        if old.nil?
          %Q(set #{attribute} to "#{new}")
        else
          %Q(changed #{attribute} from "#{old}" to "#{new}")
        end
      end.join(", ")

      ModAction.log("updated #{alias_desc}\n#{change_desc}",:tag_alias_update)
    end
  end
end
