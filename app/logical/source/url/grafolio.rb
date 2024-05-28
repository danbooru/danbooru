# frozen_string_literal: true

class Source::URL::Grafolio < Source::URL
  attr_reader :username, :user_id, :project_id, :full_image_url

  def self.match?(url)
    url.domain == "ogq.me"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://files.grafolio.ogq.me/preview/v1/content/real/566beece588b3/IMAGE/4718c558-2de0-442f-bbd8-54428c4fae7c.jpg?type=THUMBNAIL (thumbnail)
    # https://files.grafolio.ogq.me/preview/v1/content/real/8b0d026e01fc4affa9a2f232388b0edf/IMAGE/e0180515-9d3a-412e-a09b-8a55e78b282e.png?type=THUMBNAIL (thumbnail)
    in "files.grafolio", "ogq.me", "preview", "v1", "content", "real", user_id, "IMAGE", _
      @user_id = user_id
      @full_image_url = "https://files.grafolio.ogq.me/real/#{user_id}/IMAGE/#{basename}"

    # https://files.grafolio.ogq.me/real/566beece588b3/IMAGE/4718c558-2de0-442f-bbd8-54428c4fae7c.jpg (full)
    # https://files.grafolio.ogq.me/real/566beece588b3/IMAGE/cb2c9f31-44f4-4d6a-9630-6476b5234ce6.gif (full)
    # https://files.grafolio.ogq.me/real/8b0d026e01fc4affa9a2f232388b0edf/IMAGE/e0180515-9d3a-412e-a09b-8a55e78b282e.png (full)
    in "files.grafolio", "ogq.me", "real", user_id, "IMAGE", _
      @user_id = user_id
      @full_image_url = to_s

    # https://grafolio.ogq.me/project/detail/ccb07e90bdce4a868737abfca5136413
    in "grafolio", "ogq.me", "project", "detail", project_id
      @project_id = project_id

    # https://grafolio.ogq.me/profile/리니/projects
    # https://grafolio.ogq.me/profile/리니/like
    in "grafolio", "ogq.me", "profile", username, *rest
      @username = username

    # https://preview.files.api.ogq.me/v1/profile/LARGE/NEW-PROFILE/e8dce1f7/60e527f1ecd8e/b3f7f23745594ad19c5f26386110d6d8.png (profile picture)
    # https://preview.files.api.ogq.me/v1/cover/MEDIUM/NEW-PROFILE_COVER/8fa37d34/60d7843d73af8/b407e9c70b284e559816d5e787823ee2.png (profile cover image)
    else
      nil
    end
  end

  def page_url
    "https://grafolio.ogq.me/project/detail/#{project_id}" if project_id.present?
  end

  def profile_url
    "https://grafolio.ogq.me/profile/#{username}/projects" if username.present?
  end
end
