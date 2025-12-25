# frozen_string_literal: true

class Source::URL::DcInside < Source::URL
  attr_reader :full_image_url, :board_name, :post_id, :user_name

  def self.match?(url)
    url.domain.in?(%w[dcinside.co.kr dcinside.com])
  end

  def site_name
    "DC Inside"
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://dcimg8.dcinside.co.kr/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de98efa1bd62531416b0cf072989a548cbc1d4adf4728efb2c5786b58077507144c5e8b424ba8d4f071e5f71bb7f51881cd678a6d59e4c5bf7874b906 (sample)
    # https://dcimg1.dcinside.com/viewimage.php?id=3dafdf2ce0d12cab76&no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a394179b720ead53a80d89030c996204118d07dadf713bafb452d54f081&orgExt (sample)
    # https://image.dcinside.com/viewimagePop.php?no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b (full image popout)
    # https://image.dcinside.com/viewimage.php?no=24b0d769e1d32ca73de983fa11d02831c6c0b61130e4349ff064c41af1d8cfaa7bc90ab6ee250a39413de77786d73886cfa2363761a2fb20d49c71cc9afa601b (full image direct)
    in _, _, ("viewimage.php" | "viewimagePop.php") if params[:no].present?
      @full_image_url = "https://#{host}/viewimage.php?no=#{params[:no]}"

    # https://gall.dcinside.com/mgallery/board/view/?id=projectmx&no=11076518
    in "gall", _, "mgallery", "board", "view" if params[:id].present? && params[:no].present?
      @board_name = params[:id]
      @post_id = params[:no]

    # https://m.dcinside.com/board/projectmx/11076518
    in "m", _, "board", board_name, post_id
      @board_name = board_name
      @post_id = post_id

    # https://gallog.dcinside.com/mannack0106
    in "gallog", _, user_name
      @user_name = user_name

    # https://m.dcinside.com/gallog/mannack0106
    in "m", _, "gallog", user_name
      @user_name = user_name

    else
    end
  end

  def image_url?
    full_image_url.present?
  end

  def page_url
    "https://gall.dcinside.com/mgallery/board/view/?id=#{board_name}&no=#{post_id}" if board_name.present? && post_id.present?
  end

  def profile_url
    "https://gallog.dcinside.com/#{user_name}" if user_name.present?
  end
end
