class BulkUpdateRequest < ActiveRecord::Base
  attr_accessor :title, :reason

  belongs_to :user
  belongs_to :forum_topic

  validates_presence_of :user
  validates_presence_of :script
  validates_presence_of :title
  validates_inclusion_of :status, :in => %w(pending approved rejected)
  validate :script_formatted_correctly
  attr_accessible :user_id, :forum_topic_id, :script, :title, :reason
  attr_accessible :status, :as => [:admin]
  before_validation :initialize_attributes, :on => :create
  after_create :create_forum_topic

  module SearchMethods
    def search(params)
      q = where("true")
      return q if params.blank?

      if params[:id].present?
        q = q.where("id = ?", params[:id].to_i)
      end

      q
    end
  end

  extend SearchMethods

  def approve!
    AliasAndImplicationImporter.new(script, forum_topic_id, "1").process!
    update_attribute(:status, "approved")
  end

  def editable?(user)
    user_id == user.id || user.is_janitor?
  end

  def create_forum_topic
    forum_topic = ForumTopic.create(:title => "[bulk] #{title}", :category_id => 1, :original_post_attributes => {:body => reason_with_link})
    update_attribute(:forum_topic_id, forum_topic.id)
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
end
