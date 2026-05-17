require "test_helper"

module Source::Tests::URL
  class GelbooruUrlTest < ActiveSupport::TestCase
    context "Gelbooru URLs" do
      should be_image_url(
        "https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg",
        "https://video-cdn3.gelbooru.com/images/62/95/6295154d082f04009160261b90e7176e.mp4",
        "https://img2.gelbooru.com//images/a9/64/a96478bbf9bc3f0584f2b5ddf56025fa.webm",
        "https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg",
        "https://gelbooru.com/thumbnails/08/06/thumbnail_08066c138e7e138a47489a0934c29156.jpg",
        "http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png",
        "https://safebooru.org//images/4016/64779fbfc87020ed5fd94854fe973bc0.jpeg",
        "https://safebooru.org//samples/4016/sample_64779fbfc87020ed5fd94854fe973bc0.jpg?4196692",
        "https://safebooru.org/thumbnails/4016/thumbnail_64779fbfc87020ed5fd94854fe973bc0.jpg?4196692",
        "https://safebooru.org//images/4016/d2f50befcdc304cbd9030f2d0832029f5fe8cccc.png",
        "https://safebooru.org//samples/4016/sample_ffc6c5705d31422ddbaa7478deb560c985d2ee71.jpg?4196970",
        "https://safebooru.org/thumbnails/4016/thumbnail_8d0664867c59acb3103bccd9a9a5562a193eadcd.jpg?4196980",
        "https://tbib.org//images/10754/afadcf830778bd1c9bf94899ace2c889d6bf2903.png",
        "https://tbib.org//samples/10754/sample_afadcf830778bd1c9bf94899ace2c889d6bf2903.jpg?11509246",
        "https://tbib.org/thumbnails/10754/thumbnail_afadcf830778bd1c9bf94899ace2c889d6bf2903.jpg?11509246",
        "https://us.rule34.xxx//images/1802/0adc8fa0604dc445b4b47e6f4c436a08.jpeg?1949807",
        "https://api-cdn-mp4.rule34.xxx/images/4330/2f85040320f64c0e42128a8b8f6071ce.mp4",
        "https://ny5webm.rule34.xxx//images/4653/3c63956b940d0ff565faa8c7555b4686.mp4?5303486",
        "https://img.rule34.xxx//images/4977/7d76919c2f713c580f69fe129d2d1a44.jpeg?5668795",
        "https://us.rule34.xxx/thumbnails/6120/thumbnail_0a8fff70045826d2b39fcde4eed17584.jpg?6961597",
      )

      should be_page_url(
        "https://gelbooru.com/index.php?page=post&s=view&id=7798045",
        "https://www.gelbooru.com/index.php?page=post&s=view&id=7798045",
        "https://safebooru.org/index.php?page=post&s=view&id=4196948",
        "https://tbib.org/index.php?page=post&s=view&id=11509934",
        "https://rule34.xxx/index.php?page=post&s=view&id=1949807",
        "https://rule34.xxx/index.php?page=post&s=view&id=6961597",
        "https://gelbooru.com/index.php?page=post&s=list&md5=ee5c9a69db9602c95debdb9b98fb3e3e",
        "https://gelbooru.com/index.php?page=post&s=list&md5=edd1d2b3881cf70c3acf540780507531",
        "https://gelbooru.com/index.php?page=post&s=list&md5=0b3ae5e225072b8e391c827cb470d29c",
        "https://safebooru.org/index.php?page=post&s=list&md5=64779fbfc87020ed5fd94854fe973bc0",
        "https://gelbooru.com/index.php?page=dapi&s=post&q=index&id=7798045&json=1",
        "https://safebooru.org/index.php?page=dapi&s=post&q=index&id=4196948&json=1",
        "https://tbib.org/index.php?page=dapi&s=post&q=index&id=11387341&json=1",
        "https://rule34.xxx/index.php?page=dapi&s=post&q=index&id=6961597&json=1",
      )

      should parse_url("https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg").into(
        page_url: "https://gelbooru.com/index.php?page=post&s=list&md5=ee5c9a69db9602c95debdb9b98fb3e3e",
      )
      should parse_url("https://video-cdn3.gelbooru.com/images/62/95/6295154d082f04009160261b90e7176e.mp4").into(
        page_url: "https://gelbooru.com/index.php?page=post&s=list&md5=6295154d082f04009160261b90e7176e",
      )
      should parse_url("https://img2.gelbooru.com//images/a9/64/a96478bbf9bc3f0584f2b5ddf56025fa.webm").into(
        page_url: "https://gelbooru.com/index.php?page=post&s=list&md5=a96478bbf9bc3f0584f2b5ddf56025fa",
      )
      should parse_url("https://simg3.gelbooru.com//samples/0b/3a/sample_0b3ae5e225072b8e391c827cb470d29c.jpg").into(
        page_url: "https://gelbooru.com/index.php?page=post&s=list&md5=0b3ae5e225072b8e391c827cb470d29c",
      )
      should parse_url("https://gelbooru.com/thumbnails/08/06/thumbnail_08066c138e7e138a47489a0934c29156.jpg").into(
        page_url: "https://gelbooru.com/index.php?page=post&s=list&md5=08066c138e7e138a47489a0934c29156",
      )
      should parse_url("http://simg.gelbooru.com//images/2003/edd1d2b3881cf70c3acf540780507531.png").into(
        page_url: "https://gelbooru.com/index.php?page=post&s=list&md5=edd1d2b3881cf70c3acf540780507531",
      )
      should parse_url("https://gelbooru.com/index.php?page=post&s=view&id=7798045").into(
        page_url: "https://gelbooru.com/index.php?page=post&s=view&id=7798045",
      )
      should parse_url("https://www.gelbooru.com/index.php?page=post&s=view&id=7798045").into(
        page_url: "https://gelbooru.com/index.php?page=post&s=view&id=7798045",
      )
      should parse_url("https://gelbooru.com/index.php?page=dapi&s=post&q=index&id=7798045&json=1").into(
        page_url: "https://gelbooru.com/index.php?page=post&s=view&id=7798045",
      )

      should parse_url("https://safebooru.org/index.php?page=post&s=view&id=4196948").into(
        page_url: "https://safebooru.org/index.php?page=post&s=view&id=4196948",
      )
      should parse_url("https://safebooru.org/index.php?page=dapi&s=post&q=index&id=4196948&json=1").into(
        page_url: "https://safebooru.org/index.php?page=post&s=view&id=4196948",
      )
      should parse_url("https://safebooru.org//images/4016/64779fbfc87020ed5fd94854fe973bc0.jpeg").into(
        page_url: "https://safebooru.org/index.php?page=post&s=list&md5=64779fbfc87020ed5fd94854fe973bc0",
      )
      should parse_url("https://safebooru.org//samples/4016/sample_64779fbfc87020ed5fd94854fe973bc0.jpg?4196692").into(
        page_url: "https://safebooru.org/index.php?page=post&s=view&id=4196692",
      )
      should parse_url("https://safebooru.org/thumbnails/4016/thumbnail_64779fbfc87020ed5fd94854fe973bc0.jpg?4196692").into(
        page_url: "https://safebooru.org/index.php?page=post&s=view&id=4196692",
      )
      should parse_url("https://safebooru.org//images/4016/d2f50befcdc304cbd9030f2d0832029f5fe8cccc.png").into(
        page_url: nil,
      )
      should parse_url("https://safebooru.org//samples/4016/sample_ffc6c5705d31422ddbaa7478deb560c985d2ee71.jpg?4196970").into(
        page_url: "https://safebooru.org/index.php?page=post&s=view&id=4196970",
      )
      should parse_url("https://safebooru.org/thumbnails/4016/thumbnail_8d0664867c59acb3103bccd9a9a5562a193eadcd.jpg?4196980").into(
        page_url: "https://safebooru.org/index.php?page=post&s=view&id=4196980",
      )

      should parse_url("https://tbib.org/index.php?page=post&s=view&id=11509934").into(
        page_url: "https://tbib.org/index.php?page=post&s=view&id=11509934",
      )
      should parse_url("https://tbib.org/index.php?page=dapi&s=post&q=index&id=11387341&json=1").into(
        page_url: "https://tbib.org/index.php?page=post&s=view&id=11387341",
      )
      should parse_url("https://tbib.org//images/10754/afadcf830778bd1c9bf94899ace2c889d6bf2903.png").into(
        page_url: nil,
      )
      should parse_url("https://tbib.org//samples/10754/sample_afadcf830778bd1c9bf94899ace2c889d6bf2903.jpg?11509246").into(
        page_url: "https://tbib.org/index.php?page=post&s=view&id=11509246",
      )
      should parse_url("https://tbib.org/thumbnails/10754/thumbnail_afadcf830778bd1c9bf94899ace2c889d6bf2903.jpg?11509246").into(
        page_url: "https://tbib.org/index.php?page=post&s=view&id=11509246",
      )

      should parse_url("https://us.rule34.xxx//images/1802/0adc8fa0604dc445b4b47e6f4c436a08.jpeg?1949807").into(
        page_url: "https://rule34.xxx/index.php?page=post&s=view&id=1949807",
      )
      should parse_url("https://api-cdn-mp4.rule34.xxx/images/4330/2f85040320f64c0e42128a8b8f6071ce.mp4").into(
        page_url: "https://rule34.xxx/index.php?page=post&s=list&md5=2f85040320f64c0e42128a8b8f6071ce",
      )
      should parse_url("https://ny5webm.rule34.xxx//images/4653/3c63956b940d0ff565faa8c7555b4686.mp4?5303486").into(
        page_url: "https://rule34.xxx/index.php?page=post&s=view&id=5303486",
      )
      should parse_url("https://img.rule34.xxx//images/4977/7d76919c2f713c580f69fe129d2d1a44.jpeg?5668795").into(
        page_url: "https://rule34.xxx/index.php?page=post&s=view&id=5668795",
      )
      should parse_url("https://us.rule34.xxx/thumbnails/6120/thumbnail_0a8fff70045826d2b39fcde4eed17584.jpg?6961597").into(
        page_url: "https://rule34.xxx/index.php?page=post&s=view&id=6961597",
      )
      should parse_url("https://rule34.xxx/index.php?page=post&s=view&id=6961597").into(
        page_url: "https://rule34.xxx/index.php?page=post&s=view&id=6961597",
      )
      should parse_url("https://rule34.xxx/index.php?page=dapi&s=post&q=index&id=6961597&json=1").into(
        page_url: "https://rule34.xxx/index.php?page=post&s=view&id=6961597",
      )

      should parse_url("https://gelbooru.com/index.php?page=dapi&s=post&q=index&id=7798045&json=1").into(
        api_url: "https://gelbooru.com/index.php?page=dapi&s=post&q=index&tags=id:7798045",
        site_name: "Gelbooru",
      )

      should parse_url("https://safebooru.org//samples/4016/sample_ffc6c5705d31422ddbaa7478deb560c985d2ee71.jpg?4196970").into(
        site_name: "Safebooru",
      )

      should parse_url("https://tbib.org/index.php?page=dapi&s=post&q=index&id=11387341&json=1").into(
        site_name: "TBIB",
      )

      should parse_url("https://api-cdn-mp4.rule34.xxx/images/4330/2f85040320f64c0e42128a8b8f6071ce.mp4").into(
        api_url: "https://rule34.xxx/index.php?page=dapi&s=post&q=index&tags=md5:2f85040320f64c0e42128a8b8f6071ce",
        site_name: "Rule34.xxx",
      )

      should parse_url("https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg").into(
        full_image_url: "https://gelbooru.com//images/ee/5c/ee5c9a69db9602c95debdb9b98fb3e3e.jpeg",
      )

      should parse_url("https://tbib.org//images/10754/afadcf830778bd1c9bf94899ace2c889d6bf2903.png").into(
        full_image_url: "https://tbib.org//images/10754/afadcf830778bd1c9bf94899ace2c889d6bf2903.png",
      )
    end
  end
end
