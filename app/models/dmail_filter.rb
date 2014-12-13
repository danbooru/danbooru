class DmailFilter < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id, :words, :as => [:moderator, :janitor, :contributor, :gold, :member, :anonymous, :default, :builder, :admin]
  validates_presence_of :user
  before_validation :initialize_user

  def initialize_user
    unless user_id
      self.user_id = CurrentUser.user.id
    end
  end

  def filtered?(dmail)
    dmail.from.level <= User::Levels::MODERATOR && has_filter? && (dmail.body =~ regexp || dmail.title =~ regexp)
  end

  def has_filter?
    !words.strip.empty?
  end

  def regexp
    @regexp ||= Regexp.compile(words.scan(/\S+/).map {|x| Regexp.escape(x)}.join("|"))
  end
end
