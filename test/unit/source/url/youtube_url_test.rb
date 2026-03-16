require "test_helper"

module Source::Tests::URL
  class YoutubeUrlTest < ActiveSupport::TestCase
    context "Youtube URLs" do
      should be_image_url(
        "https://yt3.ggpht.com/U3N1xsa0RLryoiEUvEug69qB3Ke8gSdqXOld3kEU6T8DGCTRnAZdqW9QDt4zSRDKq_Sotb0YpZqG0RY=s1600-rw-nd-v1",
        "https://img.youtube.com/vi/dQw4w9WgXcQ/maxresdefault.jpg",
        "https://i.ytimg.com/vi/rZBBygITzyw/maxresdefault.jpg",
      )

      should be_page_url(
        "https://www.youtube.com/post/UgkxWevNfezmf-a7CRIO0haWiaDSjTI8mGsf",
        "https://www.youtube.com/channel/UCykMWf8B8I7c_jA8FTy2tGw/community?lb=UgkxWevNfezmf-a7CRIO0haWiaDSjTI8mGsf",
        "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "https://www.youtube.com/shorts/GSR2ghvoTDY",
        "https://www.youtube.com/embed/dQw4w9WgXcQ?si=Ui3IIE9NqhdTgJMx",
        "https://youtu.be/dQw4w9WgXcQ?si=i9hAbs3VV0ewqq6F",
        "https://www.youtube.com/playlist?list=OLAK5uy_noU123lqMHztLaZkpu00qEBr0thoaq1c4",
      )

      should be_profile_url(
        "https://www.youtube.com/@nonomaRui",
        "https://www.youtube.com/c/ruichnonomarui",
        "https://www.youtube.com/user/SiplickIshida",
        "https://www.youtube.com/channel/UCfrCa2Y6VulwHD3eNd3HBRA",
        "https://www.youtube.com/ruichnonomarui",
      )

      should_not be_bad_source(
        "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "https://www.youtube.com/post/UgkxWevNfezmf-a7CRIO0haWiaDSjTI8mGsf",
        "https://www.youtube.com/channel/UCykMWf8B8I7c_jA8FTy2tGw/community?lb=UgkxWevNfezmf-a7CRIO0haWiaDSjTI8mGsf",
      )
    end

    should parse_url("https://yt3.ggpht.com/U3N1xsa0RLryoiEUvEug69qB3Ke8gSdqXOld3kEU6T8DGCTRnAZdqW9QDt4zSRDKq_Sotb0YpZqG0RY=s1600-rw-nd-v1").into(site_name: "Youtube")
  end
end
