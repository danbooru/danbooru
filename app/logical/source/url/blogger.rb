# frozen_string_literal: true

class Source::URL::Blogger < Source::URL
  RESERVED_SUBDOMAINS = %w[bp cdn www]

  attr_reader :page_name, :user_id, :year, :month, :title, :full_image_url

  def self.match?(url)
    url.domain == "blogger.com" || url.sld == "blogspot" || url.host == "blogger.googleusercontent.com"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/s320/tali-litho.jpg (sample)
    # https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/s16383/tali-litho.jpg (same as s0)
    # https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/s0/tali-litho.jpg (full res, modified exif data)
    # https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/d/tali-litho.jpg (original)
    # https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/s0/ (sample)
    # https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/d/ (original)
    # https://blogger.googleusercontent.com/img/b/R29vZ2xl/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF/ (sample)
    in "blogger", "googleusercontent.com", "img", "b", subdir, image_id, *rest
      file = rest[1]
      @full_image_url = "https://blogger.googleusercontent.com/img/b/#{subdir}/#{image_id}/d/#{file}"

    # https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF (sample; 619x956 .jpg, modified exif data)
    # https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF=s0 (sample; same as s0)
    # https://blogger.googleusercontent.com/img/a/AVvXsEj6Jup0xZMWnmN6anXS4vy2nxF7FO6zX-gzBg_4vnj-7ZNFBLPhDHE82PcD9AK98LwgSjzg4qilH5VDMzOj2KDA7eH-KBTMonuTkhihMzxCT3R5qcx_8pBqbtf45ohyiXoQxfFtByFG57dF=d (original; 619x956 .jpg, unmodified exif data)
    in "blogger", "googleusercontent.com", "img", "a", image_id, *rest
      image_id = image_id.split("=").first
      @full_image_url = "https://blogger.googleusercontent.com/img/a/#{image_id}=d"

    # https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/s1600/Blog%2BImage%2B3%2B%25281%2529.png (sample; 1211x1600)
    # https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/s0/Blog%2BImage%2B3%2B%25281%2529.png (sample; 1437x1899, modified exif data)
    # https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/d/Blog%2BImage%2B3%2B%25281%2529.png (original; 1437x1899, original exif data)
    # https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/s0/ (sample)
    # https://1.bp.blogspot.com/-3JxbVuKpLkU/XQgmusYgJlI/AAAAAAAAAi4/SgRSOt9tXswtgBF_V95UROBJGx9EhjVhACLcBGAs/ (sample)
    # (source: https://security.googleblog.com/2019/06/new-chrome-protections-from-deception.html)
    #
    # https://4.bp.blogspot.com/-1ndmEdQX3AM/Tv04FWJ3kTI/AAAAAAAAAzg/P-WNaJRST6Q/s400/Bookworm%2B3.jpg (sample)
    # https://4.bp.blogspot.com/-1ndmEdQX3AM/Tv04FWJ3kTI/AAAAAAAAAzg/P-WNaJRST6Q/d/Bookworm%2B3.jpg (original)
    # https://4.bp.blogspot.com/-1ndmEdQX3AM/Tv04FWJ3kTI/AAAAAAAAAzg/P-WNaJRST6Q/s0/ (sample)
    in /^\d+\.bp$/, "blogspot.com", dir1, dir2, dir3, dir4, *rest
      file = rest[1]
      @full_image_url = "https://1.bp.blogspot.com/#{dir1}/#{dir2}/#{dir3}/#{dir4}/d/#{file}"

    # http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/s400/Copy+of+milla-jovovich-2.jpg (sample; 260x400)
    # http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/s0/Copy+of+milla-jovovich-2.jpg (sample; 800x1233, modified exif data)
    # http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/d/Copy+of+milla-jovovich-2.jpg (original; 800x1233, original exif data)
    # http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0/d/ (original)
    # http://bp0.blogger.com/_sBBi-c1S7gU/SD5OZiDWDnI/AAAAAAAAFNc/3-cwL7frca0 (sample)
    in /^bp\d+$/, "blogger.com", dir1, dir2, dir3, dir4, *rest
      file = rest[1]
      @full_image_url = "https://1.bp.blogspot.com/#{dir1}/#{dir2}/#{dir3}/#{dir4}/d/#{file}"

    # http://benbotport.blogspot.com/2011/06/mass-effect-2.html
    # http://vincentmcart.blogspot.com.es/2016/05/poison-sting.html?zx=141d0a1a4c3e3ba
    # https://www.micmicidol.club/2024/04/weekly-playboy-20240506-no19-46.html
    in _, _, /^\d{4}$/ => year, /^\d{2}$/ => month, /\.html$/
      @year = year
      @month = month
      @title = filename

    # https://vincentmcart.blogspot.com/p/blog.html
    in _, _, "p", /\.html$/
      @page_name = filename

    # https://www.blogger.com/profile/05678559930985966952
    in (nil | "www"), "blogger.com", "profile", user_id
      @user_id = user_id

    # http://photos1.blogger.com/blogger/7997/3420/1600/haruhi.jpg
    else
      nil
    end
  end

  def blog_name
    # http://benbotport.blogspot.com
    # http://vincentmcart.blogspot.com.es
    subdomain if sld == "blogspot" && !subdomain.in?(RESERVED_SUBDOMAINS) && subdomain.exclude?(".")
  end

  def blog_url
    if blog_name.present?
      "https://#{blog_name}.blogspot.com"

    # https://www.micmicidol.club
    elsif !sld.in?(%w[blogger blogspot googleusercontent])
      "https://#{host}"
    end
  end

  def image_url?
    full_image_url.present? || super
  end

  def page_url
    if blog_url.present? && year.present? && month.present? && title.present?
      "#{blog_url}/#{year}/#{month}/#{title}.html"
    elsif blog_url.present? && page_name.present?
      "#{blog_url}/p/#{page_name}.html"
    end
  end

  def profile_url
    if user_id.present?
      "https://www.blogger.com/profile/#{user_id}"
    else
      blog_url
    end
  end
end
