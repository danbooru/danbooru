require "test_helper"

module Source::Tests::URL
  class EHentaiUrlTest < ActiveSupport::TestCase
    context "E-Hentai URLs" do
      should be_image_url(
        "https://lyjrkow.ksxjubvoouva.hath.network/h/416a7c19fb25549e084876f932e2f6d45a5b2d63-1215161-2400-3589-jpg/keystamp=1683990600-aab6e15ff8;fileindex=119976531;xres=2400/89931055_p0.jpg",
        "https://hacaqjfrpvthigkeomjq.hath.network/om/119976531/188d8aec2d0ae17cfddf32849481385dd3303fc9-13295955-4379-6549-jpg/b09e528c8897a5a0ecb288f85fe9e9230d4a5f1c-483531-1280-1914-jpg/1280/v2f1fil8ij9dbk115c6/89931055_p0.jpg",
        "https://drjvktq.miqlthdkffuu.hath.network:8080/h/dce4b9677c8f769c12c8889e2581b989a3edd1bb-280532-642-802-png/keystamp=1683992100-6e1bddc318;fileindex=116114230;xres=org/1667196644017_fe0ug7p4.png",
        "https://ykofnavysaepqurqrbmv.hath.network/om/119976531/188d8aec2d0ae17cfddf32849481385dd3303fc9-13295955-4379-6549-jpg/x/0/cqq6hb0kct3sx4115c4/89931055_p0.jpg",
        "https://hacaqjfrpvthigkeomjq.hath.network/om/119976531/188d8aec2d0ae17cfddf32849481385dd3303fc9-13295955-4379-6549-jpg/b09e528c8897a5a0ecb288f85fe9e9230d4a5f1c-483531-1280-1914-jpg/1280/v2f1fil8ij9dbk115c6/89931055_p0.jpg",
        "https://e-hentai.org/r/b9f77fdd551e9ea9bb45ed18e4cd71cb03ec9a58-280138-1280-1817-wbp/forumtoken/2403312-138/kitikuourance_shokaibon_139.webp",
      )

      should be_image_sample(
        "https://lyjrkow.ksxjubvoouva.hath.network/h/416a7c19fb25549e084876f932e2f6d45a5b2d63-1215161-2400-3589-jpg/keystamp=1683990600-aab6e15ff8;fileindex=119976531;xres=2400/89931055_p0.jpg",
        "https://hacaqjfrpvthigkeomjq.hath.network/om/119976531/188d8aec2d0ae17cfddf32849481385dd3303fc9-13295955-4379-6549-jpg/b09e528c8897a5a0ecb288f85fe9e9230d4a5f1c-483531-1280-1914-jpg/1280/v2f1fil8ij9dbk115c6/89931055_p0.jpg",
      )

      should_not be_image_sample(
        "https://drjvktq.miqlthdkffuu.hath.network:8080/h/dce4b9677c8f769c12c8889e2581b989a3edd1bb-280532-642-802-png/keystamp=1683992100-6e1bddc318;fileindex=116114230;xres=org/1667196644017_fe0ug7p4.png",
        "https://ykofnavysaepqurqrbmv.hath.network/om/119976531/188d8aec2d0ae17cfddf32849481385dd3303fc9-13295955-4379-6549-jpg/x/0/cqq6hb0kct3sx4115c4/89931055_p0.jpg",
        "https://hacaqjfrpvthigkeomjq.hath.network/om/119976531/188d8aec2d0ae17cfddf32849481385dd3303fc9-13295955-4379-6549-jpg/b09e528c8897a5a0ecb288f85fe9e9230d4a5f1c-483531-1280-1914-jpg/1280/v2f1fil8ij9dbk115c6/89931055_p0.jpg",
        "https://e-hentai.org/fullimg/2403312/138/0g1swt6ak73/kitikuourance_shokaibon_139.png",
      )

      should be_page_url(
        "https://e-hentai.org/s/75c803851b/2403312-136",
        "https://exhentai.org/s/6fd82f0d38/2403312-135",
      )

      should be_bad_source(
        "https://e-hentai.org/g/2403312/71ee3b71d3",
        "https://ehtracker.org/get/2403312/485532c1cfa3b686556edf8e3906005535cc216a.torrent",
        "https://encvgvvzml.hath.network/archive/2403312/bf6b45ab72cad9e8a097b3add23f9e38a9062697/e35dpycak73/1",
      )

      should_not be_bad_source(
        "https://e-hentai.org/s/75c803851b/2403312-136",
        "https://exhentai.org/s/6fd82f0d38/2403312-135",
      )
    end

    context "when extracting attributes" do
      should parse_url("https://exhentai.org/s/75c803851b/2403312-136").into(
        page_url: "https://exhentai.org/s/75c803851b/2403312-136",
      )

      should parse_url("https://exhentai55ld2wyap5juskbm67czulomrouspdacjamjeloj7ugjbsad.onion/s/75c803851b/2403312-136").into(
        page_url: "https://exhentai.org/s/75c803851b/2403312-136",
      )

      should parse_url("https://e-hentai.org/g/2403312/71ee3b71d3/?p=6").into(
        page_url: "https://e-hentai.org/g/2403312/71ee3b71d3",
      )

      should parse_url("https://e-hentai.org/archiver.php?gid=2403312&token=71ee3b71d3").into(
        page_url: "https://e-hentai.org/g/2403312/71ee3b71d3",
      )

      should parse_url("https://e-hentai.org/gallerytorrents.php?gid=2403312&t=71ee3b71d3").into(
        page_url: "https://e-hentai.org/g/2403312/71ee3b71d3",
      )
    end

    should parse_url("https://lyjrkow.ksxjubvoouva.hath.network/h/416a7c19fb25549e084876f932e2f6d45a5b2d63-1215161-2400-3589-jpg/keystamp=1683990600-aab6e15ff8;fileindex=119976531;xres=2400/89931055_p0.jpg").into(site_name: "E-Hentai")
    should parse_url("https://exhentai55ld2wyap5juskbm67czulomrouspdacjamjeloj7ugjbsad.onion/s/6fd82f0d38/2403312-135").into(site_name: "E-Hentai")
  end
end
