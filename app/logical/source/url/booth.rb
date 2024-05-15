# frozen_string_literal: true

# Unhandled
# https://booth.pm/downloadables/1376468 (from https://booth.pm/en/items/2425521, requires pixiv login to download)

module Source
  class URL::Booth < Source::URL
    RESERVED_SUBDOMAINS = ["www", "s", "s2", "asset", "accounts", nil]

    attr_reader :work_id, :user_id, :user_uuid, :username, :full_image_url

    def self.match?(url)
      url.domain == "booth.pm" || url.host == "booth.pximg.net"
    end

    def parse
      case [subdomain, domain, *path_segments]

      # https://booth.pximg.net/8bb9e4e3-d171-4027-88df-84480480f79d/i/2864768/00cdfef0-e8d5-454b-8554-4885a7e4827d_base_resized.jpg (full)
      # https://booth.pximg.net/c/300x300_a2_g5/8bb9e4e3-d171-4027-88df-84480480f79d/i/2864768/00cdfef0-e8d5-454b-8554-4885a7e4827d_base_resized.jpg (thumb)
      # https://booth.pximg.net/c/72x72_a2_g5/8bb9e4e3-d171-4027-88df-84480480f79d/i/2864768/00cdfef0-e8d5-454b-8554-4885a7e4827d_base_resized.jpg (thumb)
      # https://booth.pximg.net/8bb9e4e3-d171-4027-88df-84480480f79d/i/2864768/00cdfef0-e8d5-454b-8554-4885a7e4827d.jpeg (full)
      #
      # https://s2.booth.pm/b242a7bd-0747-48c4-891d-9e8552edd5d7/i/3746752/52dbee27-7ad2-4048-9c1d-827eee36625c_base_resized.jpg (sample)
      # https://booth.pximg.net/b242a7bd-0747-48c4-891d-9e8552edd5d7/i/3746752/52dbee27-7ad2-4048-9c1d-827eee36625c.jpg (full)
      #
      # https://s.booth.pm/1c9bc77f-8ac1-4fa4-94e5-839772ab72cb/i/750997/774dc881-ce6e-45c6-871b-f6c3ca6914d5_base_resized.jpg (sample)
      # https://s.booth.pm/1c9bc77f-8ac1-4fa4-94e5-839772ab72cb/i/750997/774dc881-ce6e-45c6-871b-f6c3ca6914d5.png (full)
      in _, _, *, /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/i => user_uuid, "i", /^\d+$/ => work_id, _
        @user_uuid = user_uuid
        @work_id = work_id
        @full_image_url = to_s if basename.exclude?("_base_resized.jpg")

      # profile icons
      # https://booth.pximg.net/c/128x128/users/3193929/icon_image/5be9eff4-1d9e-4a79-b097-33c1cd4ad314_base_resized.jpg (sample)
      # https://booth.pximg.net/users/3193929/icon_image/5be9eff4-1d9e-4a79-b097-33c1cd4ad314.png (full)
      in _, _, *, "users", user_id, "icon_image", /^([\h-])+_base_resized/
        @user_id = user_id
        @full_image_url = to_s if basename.exclude?("_base_resized.jpg")

      # profile cover images
      # https://s2.booth.pm/8bb9e4e3-d171-4027-88df-84480480f79d/3d70de06-8e7c-444e-b8eb-a8a95bf20638_base_resized.jpg (sample)
      # https://s2.booth.pm/8bb9e4e3-d171-4027-88df-84480480f79d/3d70de06-8e7c-444e-b8eb-a8a95bf20638.png (full)
      in _, _, *, /\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/i => user_uuid, _
        @user_uuid = user_uuid
        @full_image_url = to_s if basename.exclude?("_base_resized.jpg")

      # https://booth.pm/en/items/2864768
      # https://booth.pm/ja/items/2864768
      in _, "booth.pm", _, "items", work_id
        @work_id = work_id

      # https://re-face.booth.pm/items/3435711
      in username, "booth.pm", "items", work_id unless username.in?(RESERVED_SUBDOMAINS)
        @username = username
        @work_id = work_id

      # https://re-face.booth.pm/
      # https://re-face.booth.pm/items
      # https://re-face.booth.pm/item_lists/m4ZTWzb8
      in username, "booth.pm", *rest unless username.in?(RESERVED_SUBDOMAINS)
        @username = username

      else
        nil
      end
    end

    def image_url?
      host.in?(%w[booth.pximg.net s.booth.pm s2.booth.pm])
    end

    def candidate_full_image_urls
      return [] unless image_url? && full_image_url.nil?

      %w[png jpg jpeg].map do |ext|
        full_filename = filename.delete_suffix("_base_resized")

        if user_uuid && work_id.present?
          "https://#{host}/#{user_uuid}/i/#{work_id}/#{full_filename}.#{ext}"
        elsif user_uuid.present?
          "https://#{host}/#{user_uuid}/#{full_filename}.#{ext}"
        elsif user_id
          "https://#{host}/users/#{user_id}/icon_image/#{full_filename}.#{ext}"
        end
      end
    end

    def page_url
      "https://booth.pm/en/items/#{work_id}" if work_id.present?
    end

    def api_url
      "https://booth.pm/en/items/#{work_id}.json" if work_id.present?
    end

    def profile_url
      "https://#{username}.booth.pm" if username.present?
    end
  end
end
