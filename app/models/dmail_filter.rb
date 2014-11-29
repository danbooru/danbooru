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
    dmail.from.level <= User::Levels::MODERATOR && (dmail.body =~ regexp || dmail.subject =~ regexp)
  end

  def regexp
    @regexp ||= Regexp.compile(words.scan(/\S+/).map {|x| Regexp.escape(x)}.join("|"))
  end
end
