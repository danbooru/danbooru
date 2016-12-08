class BulkUpdateRequest < ActiveRecord::Base
  attr_accessor :title, :reason, :skip_secondary_validations

  belongs_to :user
  belongs_to :forum_topic
  belongs_to :approver, :class_name => "User"

  validates_presence_of :user
  validates_presence_of :script
  validates_presence_of :title, :if => lambda {|rec| rec.forum_topic_id.blank?}
  validates_inclusion_of :status, :in => %w(pending approved rejected)
  validate :script_formatted_correctly
  validate :forum_topic_id_not_invalid
  validate :validate_script, :on => :create
  attr_accessible :user_id, :forum_topic_id, :script, :title, :reason, :skip_secondary_validations
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

  extend SearchMethods

  def approve!(approver)
    AliasAndImplicationImporter.new(script, forum_topic_id, "1", true).process!(approver)

    update({ :status => "approved", :approver_id => approver.id, :skip_secondary_validations => true }, :as => approver.role)
    update_forum_topic_for_approve

  rescue Exception => x
    self.approver = approver
    message_approver_on_failure(x)
    update_topic_on_failure(x)
  end

  def message_approver_on_failure(x)
    msg = <<-EOS
      Bulk Update Request ##{id} failed\n
      Exception: #{x.class}\n
      Message: #{x.to_s}\n
      Stack trace:\n
    EOS

    x.backtrace.each do |line|
      msg += "#{line}\n"
    end

    dmail = Dmail.new(
      :from_id => approver.id,
      :to_id => approver.id,
      :owner_id => approver.id,
      :title => "Bulk update request approval failed",
      :body => msg
    )
    dmail.owner_id = approver.id
    dmail.save
  end

  def update_topic_on_failure(x)
    if forum_topic_id
      body = "\"Bulk update request ##{id}\":/bulk_update_requests?search%5Bid%5D=#{id} failed: #{x.to_s}"
      ForumPost.create(:body => body, :topic_id => forum_topic_id)
    end
  end

  def editable?(user)
    user_id == user.id || user.is_builder?
  end

  def create_forum_topic
    if forum_topic_id
      ForumPost.create(:body => reason_with_link, :topic_id => forum_topic_id)
    else
      forum_topic = ForumTopic.create(:title => "[bulk] #{title}", :category_id => 1, :original_post_attributes => {:body => reason_with_link})
      update_attribute(:forum_topic_id, forum_topic.id)
    end
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

  def reject!
    update_forum_topic_for_reject
    update_attribute(:status, "rejected")
  end

  def initialize_attributes
    self.user_id = CurrentUser.user.id unless self.user_id
    self.status = "pending"
  end

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

  def update_forum_topic_for_approve
    if forum_topic
      forum_topic.posts.create(
        :body => "The \"bulk update request ##{id}\":/bulk_update_requests?search%5Bid%5D=#{id} has been approved."
      )
    end
  end

  def update_forum_topic_for_reject
    if forum_topic
      forum_topic.posts.create(
        :body => "The \"bulk update request ##{id}\":/bulk_update_requests?search%5Bid%5D=#{id} has been rejected."
      )
    end
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
