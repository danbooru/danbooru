# frozen_string_literal: true

class Source::URL::Facebook < Source::URL
  RESERVED_USERNAMES = %w[business friends help gaming groups marketplace people policies privacy reel watch permalink.php story.php]

  attr_reader :post_id, :photo_id, :reel_id, :user_id, :username

  def self.match?(url)
    url.domain.in?(%w[facebook.com fb.com fbcdn.net]) || url.host.match?(/^fbcdn.*\.akamaihd\.net$/)
  end

  def parse
    case [subdomain, domain, *path_segments]

    # https://scontent.fmnl9-2.fna.fbcdn.net/v/t1.6435-9/196345051_961754654392125_8855002558147907833_n.jpg?_nc_cat=103&ccb=1-5&_nc_sid=0debeb&_nc_ohc=EB1RGiEOtyEAX9XE7aL&_nc_ht=scontent.fmnl9-2.fna&oh=00_AT8NNz_keqQ6VJeC1UVSMULhjaP3iykm-ONSMR7IrtarUQ&oe=6257862E
    # https://scontent.fmnl8-2.fna.fbcdn.net/v/t1.6435-9/fr/cp0/e15/q65/80900683_480934615898749_6481759463945535488_n.jpg?_nc_cat=107&ccb=1-3&_nc_sid=8024bb&_nc_ohc=cCYFUzyHDmUAX-YHJIw&_nc_ht=scontent.fmnl8-2.fna&oh=e45c3837afcfefb6a4d93adfecef88c1&oe=60F6E392
    # https://scontent.fmnl13-1.fna.fbcdn.net/v/t31.18172-8/22861751_1362164640578443_432921612329393062_o.jpg
    # https://scontent-sin1-1.xx.fbcdn.net/hphotos-xlp1/t31.0-8/s960x960/12971037_586686358150819_495608200196301072_o.jpg
    in _, "fbcdn.net", *subdirs, /^\d+_(\d+)_(?:\d+_){1,3}[no]\.(jpg|png)$/
      @photo_id = $1

    # https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xlp1/t31.0-8/s960x960/13173066_623015164516858_1844421675339995359_o.jpg
    # https://fbcdn-sphotos-h-a.akamaihd.net/hphotos-ak-xpf1/v/t1.0-9/s720x720/12032214_991569624217563_4908408819297057893_n.png?oh=efe6ea26aed89c8a12ddc1832b1f0157&oe=5667D5B1&__gda__=1453845772_c742c726735047f2feb836b845ff296f
    in /fbcdn/, "akamaihd.net", *subdirs, /^\d+_(\d+)_(?:\d+_){1,3}[no]\.(jpg|png)$/
      @photo_id = $1

    # https://www.facebook.com/photo?fbid=1362164640578443
    in _, ("facebook.com" | "fb.com"), ("photo" | "photo.php") if params[:fbid].present?
      @photo_id = params[:fbid]

    # https://www.facebook.com/profile.php?id=100007366415557&name=xhp_nt__fblite__profile__tab_bar
    in _, ("facebook.com" | "fb.com"), ("profile" | "profile.php") if params[:id].present?
      @user_id = params[:id]

    # https://www.facebook.com/profile/100007366415557
    in _, ("facebook.com" | "fb.com"), "profile", /^\d+$/ => user_id
      @user_id = user_id

    # https://www.facebook.com/p/Chocotoffys-61550637164305/
    in _, ("facebook.com" | "fb.com"), "p", /-(\d+)$/
      @user_id = $1

    # https://www.facebook.com/people/Abandir/61565499492869/
    in _, ("facebook.com" | "fb.com"), "people", _, /^\d+$/ => user_id
      @user_id = user_id

    # https://www.facebook.com/reel/373226486954887/
    in _, ("facebook.com" | "fb.com"), "reel", /^\d+$/ => reel_id
      @reel_id = reel_id

    # https://www.facebook.com/waterring2
    # https://www.facebook.com/sinyu.tang.9
    # https://fb.com/sinyu.tang.9
    in _, ("facebook.com" | "fb.com"), username unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://www.facebook.com/sinyu.tang.9/about
    in _, ("facebook.com" | "fb.com"), username, ("about" | "reels_tab" | "photos" | "videos"), *rest unless username.in?(RESERVED_USERNAMES)
      @username = username

    # https://www.facebook.com/buttersugoi2.0/posts/pfbid052HT8bQg1QzN4V8s7wouB6DEEnP9DudwpuGPtoqgUAg9WC7Ug2Z94gYXtB2S37oBl
    # https://www.facebook.com/100045011383201/posts/845746695605598
    in _, ("facebook.com" | "fb.com"), username, "posts", post_id unless username.in?(RESERVED_USERNAMES)
      @username = username
      @post_id = post_id

    # https://www.facebook.com/permalink.php?story_fbid=<redacted>&id=100007366415557
    # https://www.facebook.com/jeffvictorart/photos/evolutio-ween-continues-with-a-new-entry-the-evolution-of-frankensteins-creature/2259697170769575/?locale=es_LA
    # https://m.facebook.com/story.php?story_fbid=pfbid02QKEpZU2xcrsHa3xnWPt16YTw49KxNMwN9PeysyybNzrEgS1AV7hze2wB6eYKfwHpl&id=61567099002989&mibextid=Nif5oz
    # https://m.facebook.com/groups/655200706208579/permalink/1270763324652311/?mibextid=Nif5oz
    else
      nil
    end
  end

  def page_url
    if username.present? && post_id.present?
      "https://www.facebook.com/#{username}/posts/#{post_id}"
    elsif photo_id.present?
      "https://www.facebook.com/photo?fbid=#{photo_id}"
    elsif reel_id.present?
      "https://www.facebook.com/reel/#{reel_id}"
    end
  end

  def profile_url
    if username.present?
      "https://www.facebook.com/#{username}"
    elsif user_id.present?
      "https://www.facebook.com/profile.php?id=#{user_id}"
    end
  end

  # XXX Remove this after all page URL formats are handled
  def bad_source?
    nil
  end

  def bad_link?
    nil
  end
end
