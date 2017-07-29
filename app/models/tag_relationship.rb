class TagRelationship < ApplicationRecord
  self.abstract_class = true

  attr_accessor :skip_secondary_validations
  attr_accessible :antecedent_name, :consequent_name, :forum_topic_id, :skip_secondary_validations
  attr_accessible :status, :approver_id, :as => [:admin]

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

    def active
      where(status: %w[active processing queued])
    end

    def search(params)
      q = where("true")
      return q if params.blank?

      if params[:id].present?
        q = q.where("id in (?)", params[:id].split(",").map(&:to_i))
      end

      if params[:name_matches].present?
        q = q.name_matches(params[:name_matches])
      end

      if params[:antecedent_name].present?
        q = q.where("antecedent_name = ?", params[:antecedent_name])
      end

      if params[:consequent_name].present?
        q = q.where("consequent_name = ?", params[:consequent_name])
      end

      case params[:order]
      when "created_at"
        q = q.order("created_at desc")
      end

      q
    end
  end

  extend SearchMethods
end
