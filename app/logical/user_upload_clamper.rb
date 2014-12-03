class UserUploadClamper
  def clamp_all!
    users.each do |user|
      if clamp_user?(user)
        clamp_user!(user)
      end
    end
  end

  def users
    User.where("post_upload_count >= 5000 and base_upload_limit is null and level <= ?", User::Levels::CONTRIBUTOR).limit(50)
  end

  def clamp_user?(user)
    Reports::UserPromotions.deletion_confidence_interval_for(user) >= 7
  end

  def clamp_user!(user)
    upload_limit = (Post.for_user(user).deleted.where("is_banned = false").count / 4) + 10
    user.update_attribute(:base_upload_limit, upload_limit)
    user.promote_to!(User::Levels::BUILDER) if user.is_contributor?
    CurrentUser.scoped(User.admins.first, "127.0.0.1") do
      Dmail.create_split(:to_id => user.id, :title => "Post Upload Limit", :body => "You are receiving this message because a large percentage of your uploads are being deleted. For this reason you will now be limited to 10 uploads a day.")
      ModAction.create(:description => "user ##{user.id} (#{user.name}) clamped")
    end
  end
end
