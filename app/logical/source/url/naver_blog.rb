# frozen_string_literal: true

# @see Source::Extractor::NaverBlog
# @see https://blog.naver.com
# @see https://raw.githubusercontent.com/qsniyg/maxurl/master/src/userscript.ts#:~:text=pstatic.net
class Source::URL::NaverBlog < Source::URL
  RESERVED_USERNAMES = %w[guestbook memo mylog prologue]

  attr_reader :username, :post_id, :full_image_url

  def self.match?(url)
    url.domain.in?(%w[naver.com blog.me naver.net pstatic.net]) && !Source::URL::NaverPost.match?(url)
  end

  def parse
    case [subdomain, domain, *path_segments]

    # http://postfiles5.naver.net/MjAxNjExMTBfMjg3/MDAxNDc4Nzc3NzU5Mzk0.NRD8udNz7DoLhl4TTB58fH-8Xm-JDhqhdHP5p4z0Nasg.EqA29GbwAWjDd4Lg5LId2z2Gk3nEXnV7rsJQtDqfTmAg.PNG.bism05/%EB%B2%A0%EB%A1%9C%EB%8B%88%EC%B9%B41.png?type=w2 (sample)
    # https://blogthumb.pstatic.net/MjAyMzA3MTFfMjkz/MDAxNjg5MDQ2NTMwMTkw.2bAkaa4r8P5vcbpyyNH3X5ysDig6q_sJ2llYrNHQ_3Ag.7b3Pxl-DcaqTAM69oiYsGHGWKOlgwWXp5BbOpVDZ98Ag.PNG.kkid9624/230623%C6%F7%B5%F0%BE%C6%B4%D4.PNG?type=w2 (sample)
    # https://mblogthumb-phinf.pstatic.net/MjAyMzA3MTFfMjkz/MDAxNjg5MDQ2NTMwMTkw.2bAkaa4r8P5vcbpyyNH3X5ysDig6q_sJ2llYrNHQ_3Ag.7b3Pxl-DcaqTAM69oiYsGHGWKOlgwWXp5BbOpVDZ98Ag.PNG.kkid9624/230623%ED%8F%AC%EB%94%94%EC%95%84%EB%8B%98.PNG?type=w80_blur (sample)
    # https://postfiles.pstatic.net/MjAxNzA5MjFfMTg1/MDAxNTA1OTk3ODQzNjU3.oR8-_8p2zkJuFfz41D_ABFDKc82luEh45nxxiH1riAUg.NqrW3NUoqqR_a3Pqbg0jAttIrNst4k5BdFG2M7WNfQsg.JPEG.bho1000/IMG_4092_resize.JPG?type=w966 (sample)
    # https://postfiles.pstatic.net/MjAyNDA0MjBfMzQg/MDAxNzEzNjIyMjM5MjY1.bA-t3pRhCcZ6t4TJKGCChhTFaO-ddv9m1tyLcdMW-4Ug.KvTzrwFNrFuB9AgQYuk0dBIGwAzeg1c3QVSrXC7TeB0g.PNG/240420%ED%91%B8%EB%A5%B4%EB%8A%AC%EB%8B%98_2.png?type=w966 (sample)
    # https://blogfiles.pstatic.net/MjAyNDA0MjBfMzQg/MDAxNzEzNjIyMjM5MjY1.bA-t3pRhCcZ6t4TJKGCChhTFaO-ddv9m1tyLcdMW-4Ug.KvTzrwFNrFuB9AgQYuk0dBIGwAzeg1c3QVSrXC7TeB0g.PNG/240420%ED%91%B8%EB%A5%B4%EB%8A%AC%EB%8B%98_2.png (full)
    #
    # https://blogfiles.pstatic.net/MjAyMjA4MDdfMzkg/MDAxNjU5ODA1OTc4MzM4.NBqjU3mCA0QD-GLbuSRQTzRQu6dJqZNWPE3zlza3c7Qg.Epzg7AX5egU5bp0kQmFV_KJuE8SLrzaR8DKx4FB90Ywg.JPEG.yanusunya/%EB%B0%B0%EA%B2%BD_.jpg/title?type=f966_600_q70 (sample)
    # https://blogfiles.pstatic.net/MjAyMjA4MDdfMzkg/MDAxNjU5ODA1OTc4MzM4.NBqjU3mCA0QD-GLbuSRQTzRQu6dJqZNWPE3zlza3c7Qg.Epzg7AX5egU5bp0kQmFV_KJuE8SLrzaR8DKx4FB90Ywg.JPEG.yanusunya/%EB%B0%B0%EA%B2%BD_.jpg/title (full)
    #
    # https://postfiles.pstatic.net/MjAxNzA5MjFfMTg1/MDAxNTA1OTk3ODQzNjU3.oR8-_8p2zkJuFfz41D_ABFDKc82luEh45nxxiH1riAUg.NqrW3NUoqqR_a3Pqbg0jAttIrNst4k5BdFG2M7WNfQsg.JPEG.bho1000/IMG_4092_resize.JPG (sample)
    # http://postfiles.naver.net/MjAxNzA5MjFfMTg1/MDAxNTA1OTk3ODQzNjU3.oR8-_8p2zkJuFfz41D_ABFDKc82luEh45nxxiH1riAUg.NqrW3NUoqqR_a3Pqbg0jAttIrNst4k5BdFG2M7WNfQsg.JPEG.bho1000/IMG_4092_resize.JPG (sample)
    # https://blogfiles.pstatic.net/MjAxNzA5MjFfMTg1/MDAxNTA1OTk3ODQzNjU3.oR8-_8p2zkJuFfz41D_ABFDKc82luEh45nxxiH1riAUg.NqrW3NUoqqR_a3Pqbg0jAttIrNst4k5BdFG2M7WNfQsg.JPEG.bho1000/IMG_4092_resize.JPG (full)
    # http://blogfiles.naver.net/MjAxNzA5MjFfMTg1/MDAxNTA1OTk3ODQzNjU3.oR8-_8p2zkJuFfz41D_ABFDKc82luEh45nxxiH1riAUg.NqrW3NUoqqR_a3Pqbg0jAttIrNst4k5BdFG2M7WNfQsg.JPEG.bho1000/IMG_4092_resize.JPG (full)
    #
    # http://mblogthumb4.phinf.naver.net/20140302_211/ttlyoung333_1393761808293P7TKj_JPEG/17.jpg?type=w2 (sample)
    # http://blogfiles.pstatic.net/20140302_211/ttlyoung333_1393761808293P7TKj_JPEG/17.jpg (full)
    # http://blogfiles.naver.net/20140302_211/ttlyoung333_1393761808293P7TKj_JPEG/17.jpg (full)
    #
    # http://blogfiles.naver.net/20120104_185/r_shughart_1325663427441woaKb_GIF/ (dead)
    in ("blogfiles" | /postfiles/ | /blogthumb/), ("naver.net" | "pstatic.net"), *rest
      # Use http:// because https://blogfiles.naver.net has an invalid certificate.
      @full_image_url = "http://blogfiles.naver.net#{path}"

    # https://blogpfthumb-phinf.pstatic.net/MjAyMzAzMThfMzIg/MDAxNjc5MDY4MjkxNzUz.ODdLT6VGaauXq9_jT-TpO878xZ--5lv0llIDclJvvTYg.yqLsxucKuBCz-auOTjpX2RRyLV_0WLCcBwb206KeCSIg.PNG.kkid9624/%EC%A0%9C%EB%B3%B8.PNG/%25EC%25A0%259C%25EB%25B3%25B8.PNG?type=s1 (sample)
    # https://blogpfthumb-phinf.pstatic.net/MjAyMzAzMThfMzIg/MDAxNjc5MDY4MjkxNzUz.ODdLT6VGaauXq9_jT-TpO878xZ--5lv0llIDclJvvTYg.yqLsxucKuBCz-auOTjpX2RRyLV_0WLCcBwb206KeCSIg.PNG.kkid9624/%EC%A0%9C%EB%B3%B8.PNG/%25EC%25A0%259C%25EB%25B3%25B8.PNG (full)
    # http://blogpfthumb.phinf.naver.net/MjAyMzAzMThfMzIg/MDAxNjc5MDY4MjkxNzUz.ODdLT6VGaauXq9_jT-TpO878xZ--5lv0llIDclJvvTYg.yqLsxucKuBCz-auOTjpX2RRyLV_0WLCcBwb206KeCSIg.PNG.kkid9624/%EC%A0%9C%EB%B3%B8.PNG/%25EC%25A0%259C%25EB%25B3%25B8.PNG (full)
    in /phinf$/, ("naver.net" | "pstatic.net"), *rest
      @full_image_url = without(:query).to_s

    # https://blog.naver.com/kkid9624/223421884109
    # https://m.blog.naver.com/goam2/221647025085
    in ("blog" | "m.blog"), "naver.com", username, /^\d+$/ => post_id
      @username = username
      @post_id = post_id

    # https://blog.naver.com/yanusunya
    # https://m.blog.naver.com/goam2?tab=1
    in ("blog" | "m.blog"), "naver.com", username, *rest unless username.in?(RESERVED_USERNAMES) || username.match?(/\.(nhn|naver)$/)
      @username = username

    # https://m.blog.naver.com/PostView.naver?blogId=fishtailia&logNo=223434964582
    # https://m.blog.naver.com/rego/BlogUserInfo.naver?blogId=fishtailia
    # https://blog.naver.com/PostList.naver?blogId=yanusunya&categoryNo=86&skinType=&skinId=&from=menu&userSelectMenu=true
    # https://blog.naver.com/NBlogTop.naver?isHttpsRedirect=true&blogId=mgrtt3132003
    # https://blog.naver.com/prologue/PrologueList.nhn?blogId=tobsua
    # https://blog.naver.com/profile/intro.naver?blogId=rlackswnd58
    in ("blog" | "m.blog"), "naver.com", *rest if params[:blogId].present?
      @username = params[:blogId]
      @post_id = params[:logNo]

    # https://rss.blog.naver.com/yanusunya.xml
    in "rss.blog", "naver.com", /\.xml$/
      @username = filename

    # https://mirun2.blog.me/ (dead link, blog.me was discontinued in ~2021)
    in username, "blog.me", *rest
      @username = username

    # https://ssl.pstatic.net/static/blog/img_ani_blogid1.gif
    # http://sstatic.naver.net/people/194/201710101543498651.jpg?type=w1
    # http://sstatic.naver.net/people/portraitGroup/201709/20170929171408460-4330243.jpg?type=w1
    # https://s.pstatic.net/shopping.phinf/20180115_4/ce3dfbda-c44b-43aa-83d0-2ffb8fa3dd47.jpg
    # https://shopping-phinf.pstatic.net/20180115_4/ce3dfbda-c44b-43aa-83d0-2ffb8fa3dd47.jpg
    else
      nil
    end
  end

  def image_url?
    domain.in?(%w[pstatic.net naver.net])
  end

  def page_url
    "https://blog.naver.com/#{username}/#{post_id}" if username.present? && post_id.present?
  end

  def profile_url
    "https://blog.naver.com/#{username}" if username.present?
  end
end
