require 'statistics2'

module Reports
  class Contributors < User
    def users
      ::User.where("users.level >= ? and users.post_upload_count >= 250", ::User::Levels::CONTRIBUTOR).order("created_at desc").limit(50).map {|x| Reports::UserPromotions::User.new(x)}
    end
  end
end
