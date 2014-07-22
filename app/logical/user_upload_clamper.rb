class UserUploadClamper
  def clamp_all!
    users.each do |user|
      if clamp_user?(user)
        clamp_user!(user)
      end
    end
  end

  def users
    User.where("post_upload_count >= 200 and (base_upload_limit > 10 or base_upload_limit is null) and level < ?", User::Levels::CONTRIBUTOR).limit(50)
  end

  def clamp_user?(user)
    Reports::UserPromotions.deletion_confidence_interval_for(user) >= 25
  end

  def clamp_user!(user)
    user.update_attribute(:base_upload_limit, -1)
    ModAction.create(:description => "user ##{user.id} (#{user.name}) clamped")
  end
end
