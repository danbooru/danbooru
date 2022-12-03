# frozen_string_literal: true

# @see https://picdig.net/
# @see Source::Extractor::Picdig
class Source::URL::Picdig < Source::URL
  RESERVED_NAMES = %w[api articles images my privacy-policy projects terms]

  attr_reader :username, :account_id, :user_id, :project_id, :image_id

  def self.match?(url)
    url.domain == "picdig.net"
  end

  def parse
    case [domain, *path_segments]

    # full: https://picdig.net/images/98a85315-ade6-42c7-b54a-a1ab7dc0c7da/54e476f5-f956-497d-b689-0db7e745907d/2021/12/b35f9c35-a37f-47b0-a5b6-e639a4535ce3.jpg (page: https://picdig.net/supercanoyan/projects/71c55605-3eca-4660-991c-ee24b9a7b684)
    # thumb: https://picdig.net/images/98a85315-ade6-42c7-b54a-a1ab7dc0c7da/54e476f5-f956-497d-b689-0db7e745907d/2021/12/63fffa1f-2862-4aa6-80dc-b5a73d91ab43.png
    in _, "images", /^[0-9a-f-]{36}$/ => account_id, /^[0-9a-f-]{36}$/ => user_id, /^\d{4}$/ => year, /^\d{2}$/ => month, /^([0-9a-f-]{36})\.\w+/
      @account_id = account_id
      @user_id = user_id
      @image_id = $1

    # avatar: https://picdig.net/images/98a85315-ade6-42c7-b54a-a1ab7dc0c7da/2021/12/9fadd3f4-c131-4f26-bce5-26c9d5bd4927.jpg
    in _, "images", /^[0-9a-f-]{36}$/ => account_id, /^\d{4}$/ => year, /^\d{2}$/ => month, /^([0-9a-f-]{36})\.\w+/
      @account_id = account_id
      @image_id = $1

    # https://picdig.net/supercanoyan/projects/71c55605-3eca-4660-991c-ee24b9a7b684
    in _, username, "projects", /^[0-9a-f-]{36}$/ => project_id
      @username = username
      @project_id = project_id

    # https://picdig.net/supercanoyan/portfolio
    # https://picdig.net/supercanoyan/profile
    # https://picdig.net/supercanoyan/collections
    # https://picdig.net/supercanoyan/articles
    in _, username, *rest unless username in RESERVED_NAMES
      @username = username

    else
      nil
    end
  end

  def image_url?
    image_id.present?
  end

  def page_url
    "https://picdig.net/#{username}/projects/#{project_id}" if username.present? && project_id.present?
  end

  def profile_url
    "https://picdig.net/#{username}/portfolio" if username.present?
  end

  def api_page_url
    "https://picdig.net/api/users/#{username}/projects/#{project_id}" if username.present? && project_id.present?
  end
end
