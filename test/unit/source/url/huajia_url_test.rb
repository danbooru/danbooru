require "test_helper"

module Source::Tests::URL
  class HuajiaUrlTest < ActiveSupport::TestCase
    context "Huajia URLs" do
      should be_image_url(
        "https://huajia.fp.ps.netease.com/file/664ae65bd56ea97215dc3e25JM5jBQGB05",
        "https://huajia.fp.ps.netease.com/file/664ae65bd56ea97215dc3e25JM5jBQGB05?fop=imageView/2/w/300/f/webp",
        "https://huajia.fp.ps.netease.com/file/67e8b79b9406b3d7123faab0q5C21Hoz06?fop=watermark/2/text/55S75Yqg77ya5LuE6KiATGltZQ==/font/5b6u6L2v6ZuF6buR/fontsize/25/fill/I0MzQzNDMw==/dissolve/20/repeat/fill/rotate/45",
      )

      should be_page_url(
        "https://huajia.163.com/main/works/8z4GdKoE",
        "https://huajia.163.com/main/goods/details/brOjJVME",
        "https://huajia.163.com/main/projects/details/1rxjP93B",
        "https://huajia.163.com/main/characterSetting/details/WEXKjKoB",
      )

      should be_profile_url(
        "https://huajia.163.com/main/profile/MBmloOn8",
        "https://huajia.163.com/main/profile/08nqxj4r?type=Works",
      )
    end
  end
end
