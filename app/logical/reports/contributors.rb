require 'statistics2'

module Reports
  class Contributors < User
    def users
      ::User.where("users.bit_prefs & ? > 0 and users.post_upload_count >= 250", ::User.flag_value_for("can_upload_free")).order("created_at desc").map {|x| Reports::UserPromotions::User.new(x)}
    end
  end
end
