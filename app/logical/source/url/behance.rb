# frozen_string_literal: true

# @see Source::Extractor::Behance
class Source::URL::Behance < Source::URL
  RESERVED_USERNAMES = %w[about assets auth blog careers entries galleries hc hire misc joblist pro search services updates]

  attr_reader :full_image_url, :project_id, :module_id, :title, :username

  def self.match?(url)
    url.domain == "behance.net"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://mir-s3-cdn-cf.behance.net/project_modules/1400/ea4c7e97612065.5ec92bae8dc45.jpg (sample)
    # https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/ea4c7e97612065.5ec92bae8dc45.jpg (sample)
    # https://mir-s3-cdn-cf.behance.net/project_modules/disp/ea4c7e97612065.5ec92bae8dc45.jpg (sample)
    # https://mir-s3-cdn-cf.behance.net/project_modules/fs/ea4c7e97612065.5ec92bae8dc45.jpg (sample)
    # https://mir-s3-cdn-cf.behance.net/project_modules/source/ea4c7e97612065.5ec92bae8dc45.jpg (full)
    in _, "behance.net", "project_modules", _, /^\h{6}(\d+)\.\h{12}/ => file
      @project_id = $1
      @full_image_url = "#{site}/project_modules/source/#{file}"

    # https://mir-cdn.behance.net/v1/rendition/project_modules/1400/828dc625691931.5634a721e19dd.jpg (sample)
    # https://mir-cdn.behance.net/v1/rendition/project_modules/source/828dc625691931.5634a721e19dd.jpg (full)
    in _, "behance.net", "v1", "rendition", "project_modules", _, /^\h{6}(\d+)\.\h{12}/ => file
      @project_id = $1
      @full_image_url = "#{site}/v1/rendition/project_modules/source/#{file}"

    # https://www.behance.net/gallery/97612065/SailorMoon
    in _, "behance.net", "gallery", project_id, title
      @project_id = project_id
      @title = title

    # https://www.behance.net/gallery/157659885/Street-food/modules/889506771
    # https://www.behance.net/gallery/97612065/SailorMoon/modules/563634913
    in _, "behance.net", "gallery", project_id, title, "modules", module_id
      @project_id = project_id
      @module_id = module_id
      @title = title

    # https://www.behance.net/Kensukecreations
    # https://www.behance.net/Kensukecreations/projects
    in _, "behance.net", username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://mir-s3-cdn-cf.behance.net/projects/404/9d2bad97612065.Y3JvcCwxMjAwLDkzOCwyODUsMzU.jpg
    else
      nil
    end
  end

  def page_url
    if project_id.present? && title.present?
      "https://www.behance.net/gallery/#{project_id}/#{title}"
    elsif project_id.present?
      "https://www.behance.net/gallery/#{project_id}/Title"
    end
  end

  def profile_url
    "https://www.behance.net/#{username}" if username.present?
  end
end
