# frozen_string_literal: true

class Source::URL::Dotpict < Source::URL
  attr_reader :username, :user_id, :work_id, :full_image_url, :candidate_full_image_urls

  def self.match?(url)
    url.domain.in?(%w[dotpict.net dotpicko.net])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://img.dotpicko.net/thumbnail_work/2023/06/09/20/57/thumb_e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.png (sample)
    # https://img.dotpicko.net/ogp_work/2023/06/09/20/57/e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.gif
    in "img", "dotpicko.net", ("thumbnail_work" | "ogp_work"), year, month, day, hour, minute, file
      @candidate_full_image_urls = %w[png gif].map do |ext|
        "#{site}/work/#{year}/#{month}/#{day}/#{hour}/#{minute}/#{filename.delete_prefix("thumb_")}.#{ext}"
      end

    # https://img.dotpicko.net/work/2023/06/09/20/57/e45a20d18dbca13bb52ae7f01eaf2de4db1054886d358bea0f36acfb7c1ce667.gif (full)
    in "img", "dotpicko.net", "work", year, month, day, hour, minute, file
      @full_image_url = to_s

    # https://dotpict.net/works/4814277
    in _, "dotpict.net", "works", work_id, *rest
      @work_id = work_id

    # https://dotpict.net/users/2011866
    # https://dotpict.net/users/2011866/followedUsers
    in _, "dotpict.net", "users", user_id, *rest
      @user_id = user_id

    # https://dotpict.net/@your_moms_house
    in _, "dotpict.net", /^@/ => username
      @username = username.delete_prefix("@")

    # https://jumpanaatta.dotpict.net/works/5356301
    in username, "dotpict.net", "works", work_id
      @username = username
      @work_id = work_id

    # https://jumpanaatta.dotpict.net/
    # https://www.dotpict.net/ (yes, this is a valid user subdomain for https://dotpict.net/@www)
    in username, "dotpict.net" unless username.nil?
      @username = username

    # https://img.dotpicko.net/0a50367ceece3eb2dda17e2e9643486f4b4950e1677bfc061ecce3c7a71c5f20.png (profile pic)
    # https://img.dotpicko.net/header_3bd62384fba07600a7247cb6093ad1ecd271adca72b8c15a5eb4263ca26c5ae2.png (profile header)
    # https://dotpict.net/search/works/tag/RainyDay2023
    else
      nil
    end
  end

  def page_url
    "https://dotpict.net/works/#{work_id}" if work_id.present?
  end

  def profile_url
    if user_id.present?
      "https://dotpict.net/users/#{user_id}"
    elsif username.present?
      "https://dotpict.net/@#{username}"
    end
  end
end
