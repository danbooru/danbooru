# frozen_string_literal: true

class Source::URL::Photozou < Source::URL
  attr_reader :user_id, :work_id

  def self.match?(url)
    url.domain == "photozou.jp"
  end

  def parse
    case [subdomain, domain, *path_segments]
    # http://art59.photozou.jp/pub/212/1986212/photo/118493247_org.v1534644005.jpg
    # http://kura3.photozou.jp/pub/741/2662741/photo/160341863_624.v1353780834.jpg
    in _, "photozou.jp", "pub", /^\d+$/, user_id, "photo", /^(\d+)/
      @user_id = user_id
      @work_id = Regexp.last_match(1)

    # http://photozou.jp/photo/top/941038
    else
      nil
    end
  end

  def page_url
    "https://photozou.jp/photo/show/#{user_id}/#{work_id}" if user_id.present? && work_id.present?
  end
end
