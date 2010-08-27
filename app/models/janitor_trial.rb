class JanitorTrial < ActiveRecord::Base
  belongs_to :user
  after_create :send_dmail
  
  def send_dmail
    body = "You have been selected as a test janitor. You can now approve pending posts and have access to the moderation interface.\n\nOver the next several weeks your approvals will be monitored. If the majority of them are quality uploads, then you will be promoted to full janitor status which grants you the ability to delete and undelete posts, ban users, and revert tag changes from vandals. If you fail the trial period, you will be demoted back to your original level and you'll receive a negative user record indicating you previously attempted and failed a test janitor trial.\n\nThere is a minimum quota of 5 approvals a week to indicate that you are being active. Remember, the goal isn't to approve as much as possible. It's to filter out borderline-quality art.\n\nIf you have any questions please respond to this message."
    
    dmail = Dmail.new(
      :title => "Test Janitor Trial Period",
      :body => body
    )
    dmail.from_id = User.admins.first.id
    dmail.to_id = user_id
    Dmail.create_new(dmail)
  end
end
