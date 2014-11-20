class DmailFilter < ActiveRecord::Base
  belongs_to :user
  attr_accessible :user_id, :words, :as => [:moderator, :janitor, :contributor, :gold, :member, :anonymous, :default, :builder, :admin]

  def filtered?(dmail)
    dmail.body =~ regexp || dmail.subject =~ regexp
  end

  def regexp
    @regexp ||= Regexp.compile(words.scan(/\S+/).map {|x| Regexp.escape(x)}.join("|"))
  end
end
