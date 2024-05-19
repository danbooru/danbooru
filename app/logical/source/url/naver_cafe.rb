# frozen_string_literal: true

# @see https://cafe.naver.com
# @see https://raw.githubusercontent.com/qsniyg/maxurl/master/src/userscript.ts#:~:text=pstatic.net
class Source::URL::NaverCafe < Source::URL
  attr_reader :full_image_url, :club_name, :club_id, :article_id, :member_id

  def self.match?(url)
    (url.domain in "naver.com" | "naver.net" | "pstatic.net") && url.subdomain in /cafe/
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://cafeptthumb-phinf.pstatic.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png?type=w800 (sample)
    # https://cafeskthumb-phinf.pstatic.net/MjAyNDA0MDFfMjkw/MDAxNzExOTQ5MTg5NzY2.8DmwoaPifD-0oadfU7t1_lKnvdamYMrnLy54eMrN9vAg.za-YKoWgxbO1dTr4Zql6sZH0FmdOsirmo3WobhB2kJgg.JPEG/maxresdefault.jpg?type=w1080 (sample)
    # https://cafefiles.pstatic.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png (full)
    # https://cafefiles.pstatic.net/MjAyNDA0MDFfMjkw/MDAxNzExOTQ5MTg5NzY2.8DmwoaPifD-0oadfU7t1_lKnvdamYMrnLy54eMrN9vAg.za-YKoWgxbO1dTr4Zql6sZH0FmdOsirmo3WobhB2kJgg.JPEG/maxresdefault.jpg (full)
    # http://cafefiles.naver.net/MjAyMDA3MDZfMTM0/MDAxNTk0MDA2Mjk0MTcw.JA_GkVUpYytyzximdxyl9Y7wtMoBHkPn2p7S3dLLAzYg.XQfw46B7G2ae5nhw7xc3wkWZgYUS9Debf_XIlsED1jgg.PNG/1.png (full)
    # http://cafefiles.naver.net/MjAyNDA0MDFfMjkw/MDAxNzExOTQ5MTg5NzY2.8DmwoaPifD-0oadfU7t1_lKnvdamYMrnLy54eMrN9vAg.za-YKoWgxbO1dTr4Zql6sZH0FmdOsirmo3WobhB2kJgg.JPEG/maxresdefault.jpg (full)
    # http://cafefiles.naver.net/20160912_57/lioneva_1473691969811MBqn4_JPEG/%BF%A1%B5%E0%C4%C9%C0%CC%C5%CD.jpg (full)
    in /cafe/, ("naver.net" | "pstatic.net"), *rest
      # Use http:// because https://cafefiles.naver.net has an invalid certificate.
      @full_image_url = "http://cafefiles.naver.net#{path}"

    # https://m.cafe.naver.com/ImageView.nhn?imageUrl=https://cafeptthumb-phinf.pstatic.net/MjAyMDEwMjFfMjIz/MDAxNjAzMjc1MTg3NjM5.waVrxNtSEW261INoEfGXuebgU4-q-IcNCg2oE7PfQ2Ug.vzDeHTJOcain0rNrITE80ulrN21UjiSEeU3X22qAEuUg.GIF/5sopu.gif
    in _, "naver.com", "ImageView.nhn" if params[:imageUrl].present?
      @full_image_url = Source::URL.parse(params[:imageUrl]).try(:full_image_url)

    # https://cafe.naver.com/common/storyphoto/viewer.html?src=https%3A%2F%2Fcafeptthumb-phinf.pstatic.net%2FMjAyMzA3MDZfMzIg%2FMDAxNjg4NjM3NzcyNDg3.CrtekTl5XiXEJCFy9532vabMKo0CaWwryTMM0Up77Jgg.8ppf2Q3uiVWUlIP6jckYwYSe5Ys-erSsd7yf8XoHECIg.PNG%2F%25EC%259C%25A0%25EC%259A%25B0%25EC%25B9%25B4_%25EC%2597%2585%25EB%25A1%259C%25EB%2593%259C%25EC%259A%25A9.png
    in _, "naver.com", "common", "storyphoto", "viewer.html" if params[:src].present?
      @full_image_url = Source::URL.parse(params[:src]).try(:full_image_url)

    # https://cafe.naver.com/ca-fe/cafes/29767250/articles/785
    in "cafe", "naver.com", "ca-fe", "cafes", club_id, "articles", article_id
      @club_id = club_id
      @article_id = article_id

    # https://m.cafe.naver.com/ca-fe/web/cafes/29767250/articles/785
    in "m.cafe", "naver.com", "ca-fe", "web", "cafes", club_id, "articles", article_id
      @club_id = club_id
      @article_id = article_id

    # https://cafe.naver.com/ca-fe/cafes/27842958/members/Iep9BEdfIxd759MU7JgtSg
    in "cafe", "naver.com", "ca-fe", "cafes", club_id, "members", member_id
      @club_id = club_id
      @member_id = member_id

    # https://cafe.naver.com/ArticleRead.nhn?clubid=29767250&articleid=793
    # https://m.cafe.naver.com/ArticleRead.nhn?clubid=29767250&articleid=793
    # https://cafe.naver.com/MyCafeIntro.nhn?clubid=29314033
    # https://cafe.naver.com/ArticleList.nhn?search.clubid=29767250&search.menuid=19
    in _, "naver.com", *rest if params[:clubid].present?
      @club_id = params[:clubid]
      @article_id = params[:articleid]

    # https://cafe.naver.com/masterofeternity/793
    # https://m.cafe.naver.com/masterofeternity/793
    in _, "naver.com", club_name, article_id
      @club_name = club_name
      @article_id = article_id

    # https://cafe.naver.com/masterofeternity
    # https://m.cafe.naver.com/masterofeternity
    # https://cafe.naver.com/nexonmoe?iframe_url=%2FArticleRead.nhn%3Fclubid%3D29767250%26articleid%3D793
    # https://cafe.naver.com/nexonmoe?iframe_url_utf8=%2FArticleRead.nhn%253Fclubid%3D29767250%2526articleid%3D793
    # https://cafe.naver.com/masterofeternity?iframe_url=/MyCafeIntro.nhn%3Fclubid=29314033
    in _, "naver.com", club_name
      relative_url = params[:iframe_url] || params[:iframe_url_utf8]
      url = Source::URL.parse("https://cafe.naver.com#{relative_url}")

      @club_name = club_name
      @club_id = url.try(:club_id)
      @article_id = url.try(:article_id)

    # https://cafe.naver.com/ca-fe/cafes/29767250/members/hgoxi0a3Zv2O7xQinIz4yw
    # https://apis.naver.com/cafe-web/cafe2/CafeGateInfo.json?cafeId=29767250
    # https://apis.naver.com/cafe-web/cafe2/CafeMemberInfo.json?cafeId=29613463
    # https://apis.naver.com/cafe-web/cafe-articleapi/v2.1/cafes/29613463/articles/810?query=&useCafeId=true&requestFrom=A
    else
      nil
    end
  end

  def image_url?
    domain.in?(%w[pstatic.net naver.net])
  end

  def page_url
    if club_id.present? && article_id.present?
      "https://cafe.naver.com/ca-fe/cafes/#{club_id}/articles/#{article_id}"
    elsif club_name.present? && article_id.present?
      "https://cafe.naver.com/#{club_name}/#{article_id}"
    end
  end

  def profile_url
    if club_id.present? && member_id.present?
      "https://cafe.naver.com/ca-fe/cafes/#{club_id}/members/#{member_id}"
    elsif club_name.present?
      "https://cafe.naver.com/#{club_name}"
    elsif club_id.present?
      "https://cafe.naver.com/MyCafeIntro.nhn?clubid=#{club_id}"
    end
  end
end
