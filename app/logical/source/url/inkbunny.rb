# frozen_string_literal: true

class Source::URL::Inkbunny < Source::URL
  attr_reader :username, :user_id, :submission_id

  def self.match?(url)
    url.domain == "inkbunny.net" || url.host.end_with?(".ib.metapix.net")
  end

  def parse
    case [domain, *path_segments]

    # https://inkbunny.net/s/3200751
    in "inkbunny.net", "s", /^(\d+)[a-zA-Z0-9-]*$/ => submission_id
      @submission_id = $1.to_i

    # https://inkbunny.net/submissionview.php?id=3200751
    in "inkbunny.net", "submissionview.php" if params[:id].present?
      @submission_id = params[:id].to_i

    # https://inkbunny.net/DAGASI
    in "inkbunny.net", /^[a-zA-Z0-9]+$/ => username
      @username = username

    # https://inkbunny.net/user.php?user_id=152800
    in "inkbunny.net", "user.php" if params[:user_id].present?
      @user_id = params[:user_id].to_i

    else
      nil
    end
  end

  def image_url?
    url.host.end_with?(".ib.metapix.net")
  end

  def page_url
    "https://inkbunny.net/s/#{submission_id}" if submission_id.present?
  end

  def profile_url
    if username.present?
      "https://inkbunny.net/#{username}"
    elsif user_id.present?
      "https://inkbunny.net/user.php?user_id=#{user_id}"
    end
  end
end
