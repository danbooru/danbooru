class BulkUpdateRequest < ActiveRecord::Base
  attr_accessor :reason, :skip_secondary_validations

  belongs_to :user
  belongs_to :forum_topic
  belongs_to :forum_post
  belongs_to :approver, :class_name => "User"

  validates_presence_of :user
  validates_presence_of :script
  validates_presence_of :title, :if => lambda {|rec| rec.forum_topic_id.blank?}
  validates_inclusion_of :status, :in => %w(pending approved rejected)
  validate :script_formatted_correctly
  validate :forum_topic_id_not_invalid
  validate :validate_script, :on => :create
  attr_accessible :user_id, :forum_topic_id, :forum_post_id, :script, :title, :reason, :skip_secondary_validations
  attr_accessible :status, :approver_id, :as => [:admin]
  before_validation :initialize_attributes, :on => :create
  before_validation :normalize_text
  after_create :create_forum_topic

  module SearchMethods
    def search(params)
      q = where("true")
      return q if params.blank?

      if params[:id].present?
        q = q.where("id in (?)", params[:id].split(",").map(&:to_i))
      end

      q
    end
  end

  module ApprovalMethods
    def forum_updater
      @forum_updater ||= begin
        post = if forum_topic
          forum_post || forum_topic.posts.first
        else
          nil
        end
        ForumUpdater.new(
          forum_topic, 
          forum_post: post, 
          expected_title: title
        )
      end
    end

    def approve!(approver)
      CurrentUser.scoped(approver) do
        AliasAndImplicationImporter.new(script, forum_topic_id, "1", true).process!
        update({ :status => "approved", :approver_id => CurrentUser.id, :skip_secondary_validations => true }, :as => CurrentUser.role)
        forum_updater.update("The \"bulk update request ##{id}\":/bulk_update_requests?search%5Bid%5D=#{id} has been approved.", "APPROVED")
      end

    rescue Exception => x
      self.approver = approver
      CurrentUser.scoped(approver) do
        forum_updater.update("The \"Bulk update request ##{id}\":/bulk_update_requests?search%5Bid%5D=#{id} has failed: #{x.to_s}", "FAILED")
      end
    end

    def date_timestamp
      Time.now.strftime("%Y-%m-%d")
    end

    def create_forum_topic
      if forum_topic_id
        forum_post = forum_topic.posts.create(body: reason_with_link)
        update_attributes(:forum_post_id => forum_post.id)
      else
        forum_topic = ForumTopic.create(:title => title, :category_id => 1, :original_post_attributes => {:body => reason_with_link})
        update_attributes(:forum_topic_id => forum_topic.id, :forum_post_id => forum_topic.posts.first.id)
      end
    end

    def reject!
      forum_updater.update("The \"bulk update request ##{id}\":/bulk_update_requests?search%5Bid%5D=#{id} has been rejected.", "REJECTED")
      update_attribute(:status, "rejected")
    end
  end

  module ValidationMethods
    def script_formatted_correctly
      AliasAndImplicationImporter.tokenize(script)
      return true
    rescue StandardError => e
      errors.add(:base, e.message)
      return false
    end

    def forum_topic_id_not_invalid
      if forum_topic_id && !forum_topic
        errors.add(:base, "Forum topic ID is invalid")
      end
    end

    def validate_script
      begin
        AliasAndImplicationImporter.new(script, forum_topic_id, "1", skip_secondary_validations).validate!
      rescue RuntimeError => e
        self.errors[:base] = e.message
        return false
      end

      errors.empty?
    end
  end

  extend SearchMethods
  include ApprovalMethods
  include ValidationMethods

  def editable?(user)
    user_id == user.id || user.is_builder?
  end

  def reason_with_link
    "#{script_with_links}\n\n\"Link to request\":/bulk_update_requests?search[id]=#{id}\n\n#{reason}"
  end

  def script_with_links
    tokens = AliasAndImplicationImporter.tokenize(script)
    lines = tokens.map do |token|
      case token[0]
      when :create_alias, :create_implication, :remove_alias, :remove_implication
        "#{token[0].to_s.tr("_", " ")} [[#{token[1]}]] -> [[#{token[2]}]]"

      when :mass_update
        "mass update {{#{token[1]}}} -> #{token[2]}"

      else
        raise "Unknown token: #{token[0]}"
      end
    end
    lines.join("\n")
  end

  def initialize_attributes
    self.user_id = CurrentUser.user.id unless self.user_id
    self.status = "pending"
  end

  def normalize_text
    self.script = script.downcase
  end

  def skip_secondary_validations=(v)
    if v == "1" or v == true
      @skip_secondary_validations = true
    else
      @skip_secondary_validations = false
    end
  end
end
