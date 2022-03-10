# frozen_string_literal: true

module Source
  class URL::Stash < Source::URL
    attr_reader :work_id, :username

    def self.match?(url)
      url.domain == "sta.sh"
    end

    def site_name
      "Sta.sh"
    end

    def parse
      case [domain, *path_segments]

      # https://sta.sh/21leo8mz87ue (folder)
      # https://sta.sh/2uk0v5wabdt (subfolder)
      # https://sta.sh/0wxs31o7nn2 (single image)
      in "sta.sh", work_id
        @work_id = work_id

      # https://sta.sh/zip/21leo8mz87ue
      in "sta.sh", "zip", work_id
        @work_id = work_id

      else
      end
    end

    def page_url
      "https://sta.sh/#{work_id}"
    end
  end
end
