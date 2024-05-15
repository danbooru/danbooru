# frozen_string_literal: true

class Source::URL::Galleria < Source::URL
  attr_reader :user_id, :post_id, :full_image_url

  def self.match?(url)
    url.domain == "emotionflow.com"
  end

  def site_name
    "Galleria"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://galleria-img.emotionflow.com/user_img9/40775/i660870_869.jpeg
    # https://galleria-img.emotionflow.com/user_img9/75596/c635025_810.jpeg
    # https://galleria-img.emotionflow.com/user_img9/75596/i1549553512126_164.jpeg
    # http://img01.emotionflow.com/galleria/user_img6/14169/141693874499122908405.png
    # http://galleria.emotionflow.com/user_img6/12915/1291531674451216.png_480.jpg (sample)
    # https://galleria-img.emotionflow.com/user_img9/38279/i679579_387.jpeg_360.jpg?0716161312 (sample)
    # https://galleria-img.emotionflow.com/user_img9/38279/i679579_387.jpeg (full)
    in _, "emotionflow.com", *subdirs, /^user_img\d+$/, /^\d+$/ => user_id, _
      @user_id = user_id
      @post_id = filename[/\A[ci](\d{1,7})/, 1]
      @full_image_url = without(:query).to_s.gsub(/\.(jpeg|jpg|png|gif)_\d+\.jpg\z/, '.\1') # ".png_480.jpg" => ".png"

    # https://galleria.emotionflow.com/40775/660870.html
    # https://galleria.emotionflow.com/s/40775/660870.html
    in "galleria", "emotionflow.com", *subdirs, /^\d+$/ => user_id, /^\d+\.html$/
      @user_id = user_id
      @post_id = filename

    # https://galleria.emotionflow.com/IllustDetailV.jsp?ID=136703&TD=701021
    # https://galleria.emotionflow.com/s/IllustDetailV.jsp?ID=136703&TD=701021
    in "galleria", "emotionflow.com", *subdirs, "IllustDetailV.jsp"
      @user_id = params["ID"]
      @post_id = params["TD"]

    # http://galleria.emotionflow.com/GalleryListGridV.jsp?ID=15878
    # http://galleria.emotionflow.com/s/GalleryListGridV.jsp?ID=1171
    # http://galleria.emotionflow.com/MyGalleryListV.jsp?ID=40948
    # http://galleria.emotionflow.com/s/MyGalleryListV.jsp?ID=40948
    in "galleria", "emotionflow.com", *subdirs, ("GalleryListGridV.jsp" | "MyGalleryListV.jsp")
      @user_id = params["ID"]

    # https://galleria.emotionflow.com/40775/gallery.html
    # https://galleria.emotionflow.com/40775/創作/
    # http://temp.emotionflow.com/7289/
    in ("galleria" | "temp"), "emotionflow.com", /^\d+$/ => user_id, *rest
      @user_id = user_id

    # https://galleria.emotionflow.com/s/40775/gallery.html
    in ("galleria" | "temp"), "emotionflow.com", "s", /^\d+$/ => user_id, *rest
      @user_id = user_id

    else
      nil
    end
  end

  def page_url
    "https://galleria.emotionflow.com/#{user_id}/#{post_id}.html" if user_id.present? && post_id.present?
  end

  def profile_url
    "https://galleria.emotionflow.com/#{user_id}/" if user_id.present?
  end
end
