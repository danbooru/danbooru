# frozen_string_literal: true

module Source
  class URL
    class Huajia < Source::URL
      attr_reader :user_id, :work_id, :goods_id, :commission_id, :cs_id, :full_image_url

      def self.match?(url)
        url.host.in?(%w[huajia.163.com huajia.fp.ps.netease.com])
      end

      def parse
        case [subdomain, domain, *path_segments]

        # https://huajia.fp.ps.netease.com/file/664ae65bd56ea97215dc3e25JM5jBQGB05
        # https://huajia.fp.ps.netease.com/file/664ae65bd56ea97215dc3e25JM5jBQGB05?fop=imageView/2/w/300/f/webp
        # https://huajia.fp.ps.netease.com/file/67e8b79b9406b3d7123faab0q5C21Hoz06?fop=watermark/2/text/55S75Yqg77ya5LuE6KiATGltZQ==/font/5b6u6L2v6ZuF6buR/fontsize/25/fill/I0MzQzNDMw==/dissolve/20/repeat/fill/rotate/45
        in "huajia.fp.ps", "netease.com", "file", file
          @full_image_url = without(:query).to_s

        # https://huajia.163.com/main/works/8z4GdKoE
        in "huajia", "163.com", "main", "works", work_id
          @work_id = work_id

        # https://huajia.163.com/main/goods/details/brOjJVME
        in "huajia", "163.com", "main", "goods", "details", goods_id
          @goods_id = goods_id

        # https://huajia.163.com/main/projects/details/1rxjP93B
        # https://huajia.163.com/main/projects/details/08nVl458
        # https://huajia.163.com/main/projects/details/vE7eDV68
        in "huajia", "163.com", "main", "projects", "details", commission_id
          @commission_id = commission_id

        # https://huajia.163.com/main/characterSetting/details/WEXKjKoB
        # https://huajia.163.com/main/characterSetting/details/VENW40Kr
        # https://huajia.163.com/main/characterSetting/details/vE79wa28
        # (cookie required)
        in "huajia", "163.com", "main", "characterSetting", "details", cs_id
          @cs_id = cs_id

        # https://huajia.163.com/main/profile/MBmloOn8
        # https://huajia.163.com/main/profile/08nqxj4r?type=Works
        in "huajia", "163.com", "main", "profile", user_id
          @user_id = user_id

        else
          nil
        end
      end

      def image_url?
        host == "huajia.fp.ps.netease.com"
      end

      def page_url
        if work_id.present?
          "https://huajia.163.com/main/works/#{work_id}"
        elsif goods_id.present?
          "https://huajia.163.com/main/goods/details/#{goods_id}"
        elsif commission_id.present?
          "https://huajia.163.com/main/projects/details/#{commission_id}"
        elsif cs_id.present?
          "https://huajia.163.com/main/characterSetting/details/#{cs_id}"
        end
      end

      def profile_url
        if user_id.present?
          "https://huajia.163.com/main/profile/#{user_id}"
        end
      end
    end
  end
end
