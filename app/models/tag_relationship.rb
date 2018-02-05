class TagRelationship < ApplicationRecord
  self.abstract_class = true

  attr_accessor :skip_secondary_validations

  belongs_to :creator, :class_name => "User"
  belongs_to :approver, :class_name => "User"
  belongs_to :forum_post
  belongs_to :forum_topic
  has_one :antecedent_tag, :class_name => "Tag", :foreign_key => "name", :primary_key => "antecedent_name"
  has_one :consequent_tag, :class_name => "Tag", :foreign_key => "name", :primary_key => "consequent_name"

  before_validation :initialize_creator, :on => :create
  before_validation :normalize_names
  validates_format_of :status, :with => /\A(active|deleted|pending|processing|queued|error: .*)\Z/
  validates_presence_of :creator_id, :antecedent_name, :consequent_name
  validates :creator, presence: { message: "must exist" }, if: lambda { creator_id.present? }
  validates :approver, presence: { message: "must exist" }, if: lambda { approver_id.present? }
  validates :forum_topic, presence: { message: "must exist" }, if: lambda { forum_topic_id.present? }

  def initialize_creator
    self.creator_id = CurrentUser.user.id
    self.creator_ip_addr = CurrentUser.ip_addr
  end

  def normalize_names
    self.antecedent_name = antecedent_name.mb_chars.downcase.tr(" ", "_")
    self.consequent_name = consequent_name.mb_chars.downcase.tr(" ", "_")
  end

  def is_pending?
    status == "pending"
  end

  def is_active?
    status == "active"
  end

  def deletable_by?(user)
    return true if user.is_admin?
    return true if is_pending? && user.is_builder?
    return true if is_pending? && user.id == creator_id
    return false
  end

  def editable_by?(user)
    deletable_by?(user)
  end

  module SearchMethods
    def name_matches(name)
      where("(antecedent_name like ? escape E'\\\\' or consequent_name like ? escape E'\\\\')", name.mb_chars.downcase.to_escaped_for_sql_like, name.mb_chars.downcase.to_escaped_for_sql_like)
    end

    def status_matches(status)
      status = status.downcase

      if status == "approved"
        where(status: %w[active processing queued])
      else
        where(status: status)
      end
    end

    def pending_first
      order("(case status when 'pending' then 1 when 'queued' then 2 when 'active' then 3 else 0 end), antecedent_name, consequent_name")
    end

    def active
      where(status: %w[active processing queued])
    end

    def default_order
      pending_first
    end

    def search(params)
      q = super

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:antecedent_name].present?
        q = q.where(antecedent_name: params[:antecedent_name].split)
      end

      if params[:consequent_name].present?
        q = q.where(consequent_name: params[:consequent_name].split)
      end

      if params[:status].present?
        q = q.status_matches(params[:status])
      end

      if params[:category].present?
        q = q.joins(:consequent_tag).where("tags.category": params[:category].split)
      end

      params[:order] ||= "status"
      case params[:order].downcase
      when "created_at"
        q = q.order("created_at desc")
      when "updated_at"
        q = q.order("updated_at desc")
      when "name"
        q = q.order("antecedent_name asc, consequent_name asc")
      when "tag_count"
        q = q.joins(:consequent_tag).order("tags.post_count desc, antecedent_name asc, consequent_name asc")
      else
        q = q.apply_default_order(params)
      end

      q
    end
  end

  module MessageMethods
    def relationship
      # "TagAlias" -> "tag alias", "TagImplication" -> "tag implication"
      self.class.name.underscore.tr("_", " ")
    end

    def approval_message(approver)
      "The #{relationship} [[#{antecedent_name}]] -> [[#{consequent_name}]] #{forum_link} has been approved by @#{approver.name}."
    end

    def failure_message(e = nil)
      "The #{relationship} [[#{antecedent_name}]] -> [[#{consequent_name}]] #{forum_link} failed during processing. Reason: #{e}"
    end

    def reject_message(rejector)
      "The #{relationship} [[#{antecedent_name}]] -> [[#{consequent_name}]] #{forum_link} has been rejected by @#{rejector.name}."
    end

    def conflict_message
      "The tag alias [[#{antecedent_name}]] -> [[#{consequent_name}]] #{forum_link} has conflicting wiki pages. [[#{consequent_name}]] should be updated to include information from [[#{antecedent_name}]] if necessary."
    end

    def date_timestamp
      Time.now.strftime("%Y-%m-%d")
    end

    def forum_link
      "(forum ##{forum_post.id})" if forum_post.present?
    end
  end

  extend SearchMethods
  include MessageMethods
end
