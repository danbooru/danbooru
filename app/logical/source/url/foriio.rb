# frozen_string_literal: true

class Source::URL::Foriio < Source::URL
  RESERVED_USERNAMES = %w[about benefits business company contests discover keywords legal pro]

  attr_reader :username, :work_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[foriio.com fori.io]) ||
      url.host.in?(%w[foriio.imgix.net foriio-og-images.s3.ap-northeast-1.amazonaws.com dyci7co52mbcc.cloudfront.net])
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://foriio.imgix.net/store/46d77f4f772f191d04c9360180cc907d.jpg?ixlib=rb-4.1.0&w=2184&auto=compress&s=a9a14e871e2f6dbdc28f87c915e8684f (sample)
    # https://foriio.imgix.net/store/46d77f4f772f191d04c9360180cc907d.jpg (full)
    in _, "imgix.net", *rest
      @full_image_url = without(:query).to_s

    # https://www.foriio.com/works/600743
    in _, _, "works", work_id
      @work_id = work_id

    # https://www.foriio.com/embeded/works/600743
    in _, _, "embeded", "works", work_id
      @work_id = work_id

    # https://fori.io/comori22
    # https://www.foriio.com/comori22
    # https://www.foriio.com/comori22/categories/Illustration
    in _, _, username, *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://foriio-og-images.s3.ap-northeast-1.amazonaws.com/407656ab2d5c71a1d3b5745bcce16544
    # https://foriio-og-thumbs.s3.ap-northeast-1.amazonaws.com/0681cb32dff4d90465e045cca348ace8.jpg
    # https://og-image-v2.foriio.com/api/og?avatar=https://dyci7co52mbcc.cloudfront.net/store/8e4827d9abbc957ef333917a15f71d1e.png&profession=%E3%82%A4%E3%83%A9%E3%82%B9%E3%83%88%E3%83%AC%E3%83%BC%E3%82%BF%E3%83%BC&accept_request=false&name=%E3%81%93%E3%82%82%E3%82%8A&lang=ja&image=https%3A%2F%2Fforiio.imgix.net%2Fstore%2Fc1ebfd02eef881584e8c1aaacca3dff6.jpeg%3Fixlib%3Drb-3.1.1%26auto%3Dcompress%26w%3D688%26h%3D424%26fit%3Dfacearea%26facepad%3D10%26s%3Dcff117b12bb642dfbc28cb67beac7275&template=single_work
    # https://dyci7co52mbcc.cloudfront.net/store/8e4827d9abbc957ef333917a15f71d1e.png
    else
      nil
    end
  end

  def image_url?
    domain.in?(%w[imgix.net amazonaws.com cloudfront.net])
  end

  def page_url
    "https://www.foriio.com/works/#{work_id}" if work_id.present?
  end

  def profile_url
    "https://www.foriio.com/#{username}" if username.present?
  end
end
