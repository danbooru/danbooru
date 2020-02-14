class PostDisapproval < ApplicationRecord
  DELETION_THRESHOLD = 1.month

  belongs_to :post
  belongs_to :user
  after_initialize :initialize_attributes, if: :new_record?
  validates_uniqueness_of :post_id, :scope => [:user_id], :message => "have already hidden this post"
  validates_inclusion_of :reason, :in => %w(legacy breaks_rules poor_quality disinterest)

  scope :with_message, -> {where("message is not null and message <> ''")}
  scope :without_message, -> {where("message is null or message = ''")}
  scope :breaks_rules, -> {where(:reason => "breaks_rules")}
  scope :poor_quality, -> {where(:reason => "poor_quality")}
  scope :disinterest, -> {where(:reason => ["disinterest", "legacy"])}

  def initialize_attributes
    self.user_id ||= CurrentUser.user.id
  end

  def self.prune!
    PostDisapproval.where("post_id in (select _.post_id from post_disapprovals _ where _.created_at < ?)", DELETION_THRESHOLD.ago).delete_all
  end

  def self.dmail_messages!
    disapprovals = PostDisapproval.with_message.where("created_at >= ?", 1.day.ago).group_by do |pd|
      pd.post.uploader
    end

    disapprovals.each do |uploader, list|
      message = list.map do |x|
        "* post ##{x.post_id}: #{x.message}"
      end.join("\n")

      Dmail.create_automated(
        :to_id => uploader.id,
        :title => "Someone has commented on your uploads",
        :body => message
      )
    end
  end

  def create_downvote
    if %w(breaks_rules poor_quality).include?(reason)
      PostVote.create(:score => -1, :post_id => post_id)
    end
  end

  concerning :SearchMethods do
    class_methods do
      def search(params)
        q = super

        q = q.search_attributes(params, :post, :user, :message, :reason)
        q = q.text_attribute_matches(:message, params[:message_matches])

        q = q.with_message if params[:has_message].to_s.truthy?
        q = q.without_message if params[:has_message].to_s.falsy?

        case params[:order]
        when "post_id", "post_id_desc"
          q = q.order(post_id: :desc, id: :desc)
        else
          q = q.apply_default_order(params)
        end

        q
      end
    end
  end

  def self.available_includes
    [:user, :post]
  end
end
