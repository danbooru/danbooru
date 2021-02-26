module IconHelper
  def icon_tag(icon_class, class: nil, **options)
    klass = binding.local_variable_get(:class)
    tag.i(class: "icon #{icon_class} #{klass}", **options)
  end

  def svg_icon_tag(type, path, class: nil, **options)
    klass = binding.local_variable_get(:class)
    tag.svg(class: "icon svg-icon #{type} #{klass}", role: "img", xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 448 512", **options) do
      tag.path(fill: "currentColor", d: path)
    end
  end

  def image_icon_tag(filename, class: nil, **options)
    klass = binding.local_variable_get(:class)
    tag.img(src: "/images/#{filename}", class: "icon #{klass}", **options)
  end

  # fontawesome.com/icons/arrow-alt-up
  def upvote_icon(**options)
    svg_icon_tag("upvote-icon", "M272 480h-96c-13.3 0-24-10.7-24-24V256H48.2c-21.4 0-32.1-25.8-17-41L207 39c9.4-9.4 24.6-9.4 34 0l175.8 176c15.1 15.1 4.4 41-17 41H296v200c0 13.3-10.7 24-24 24z", **options)
  end

  # fontawesome.com/icons/arrow-alt-down
  def downvote_icon(**options)
    svg_icon_tag("downvote-icon", "M176 32h96c13.3 0 24 10.7 24 24v200h103.8c21.4 0 32.1 25.8 17 41L241 473c-9.4 9.4-24.6 9.4-34 0L31.3 297c-15.1-15.1-4.4-41 17-41H152V56c0-13.3 10.7-24 24-24z", **options)
  end

  def sticky_icon(**options)
    icon_tag("fas fa-thumbtack", **options)
  end

  def lock_icon(**options)
    icon_tag("fas fa-lock", **options)
  end

  def delete_icon(**options)
    icon_tag("fas fa-trash-alt", **options)
  end

  def undelete_icon(**options)
    icon_tag("fas fa-trash-restore_alt", **options)
  end

  def private_icon(**options)
    icon_tag("fas fa-hand-paper", **options)
  end

  def menu_icon(**options)
    icon_tag("fas fa-bars", **options)
  end

  def close_icon(**options)
    icon_tag("fas fa-times", **options)
  end

  def search_icon(**options)
    icon_tag("fas fa-search", **options)
  end

  def bookmark_icon(**options)
    icon_tag("fas fa-bookmark", **options)
  end

  def empty_heart_icon(**options)
    icon_tag("far fa-heart", **options)
  end

  def solid_heart_icon(**options)
    icon_tag("fas fa-heart", **options)
  end

  def comments_icon(**options)
    icon_tag("far fa-comments", **options)
  end

  def spinner_icon(**options)
    icon_tag("fas fa-spinner fa-spin", **options)
  end

  def external_link_icon(**options)
    icon_tag("fas fa-external-link-alt", **options)
  end

  def checkmark_icon(**options)
    icon_tag("fas fa-check-circle", **options)
  end

  def exclamation_icon(**options)
    icon_tag("fas fa-exclamation-triangle", **options)
  end

  def meh_icon(**options)
    icon_tag("far fa-meh", **options)
  end

  def avatar_icon(**options)
    icon_tag("fas fa-user-circle", **options)
  end

  def medal_icon(**options)
    icon_tag("fas fa-medal", **options)
  end

  def negative_icon(**options)
    icon_tag("fas fa-times-circle", **options)
  end

  def message_icon(**options)
    icon_tag("far fa-envelope", **options)
  end

  def gift_icon(**options)
    icon_tag("fas fa-gift", **options)
  end

  def feedback_icon(**options)
    icon_tag("fas fa-file-signature", **options)
  end

  def promotion_icon(**options)
    icon_tag("fas fa-user-plus", **options)
  end

  def ban_icon(**options)
    icon_tag("fas fa-user-slash", **options)
  end

  def chevron_left_icon(**options)
    icon_tag("fas fa-chevron-left", **options)
  end

  def chevron_right_icon(**options)
    icon_tag("fas fa-chevron-right", **options)
  end

  def ellipsis_icon(**options)
    icon_tag("fas fa-ellipsis-h", **options)
  end

  def edit_icon(**options)
    icon_tag("fas fa-edit", **options)
  end

  def flag_icon(**options)
    icon_tag("fas fa-flag", **options)
  end

  def link_icon(**options)
    icon_tag("fas fa-link", **options)
  end

  def plus_icon(**options)
    icon_tag("fas fa-plus", **options)
  end

  def globe_icon(**options)
    icon_tag("fas fa-globe", **options)
  end

  def discord_icon(**options)
    image_icon_tag("discord-logo.png", **options)
  end

  def github_icon(**options)
    image_icon_tag("github-logo.png", **options)
  end

  def twitter_icon(**options)
    image_icon_tag("twitter-logo.png", **options)
  end

  def external_site_icon(site_name, **options)
    case site_name
    when "ArtStation"
      image_icon_tag("artstation-logo.png", **options)
    when "BCY"
      image_icon_tag("bcy-logo.png", **options)
    when "Booth.pm"
      image_icon_tag("booth-pm-logo.png", **options)
    when "Circle.ms"
      image_icon_tag("circle-ms-logo.png", **options)
    when "DLSite"
      image_icon_tag("dlsite-logo.png", **options)
    when "Deviant Art"
      image_icon_tag("deviantart-logo.png", **options)
    when "Facebook"
      image_icon_tag("facebook-logo.png", **options)
    when "Fantia"
      image_icon_tag("fantia-logo.png", **options)
    when "FC2"
      image_icon_tag("fc2-logo.png", **options)
    when "Gumroad"
      image_icon_tag("gumroad-logo.png", **options)
    when "Instagram"
      image_icon_tag("instagram-logo.png", **options)
    when "Lofter"
      image_icon_tag("lofter-logo.png", **options)
    when "Melonbooks"
      image_icon_tag("melonbooks-logo.png", **options)
    when "Nico Seiga"
      image_icon_tag("nicoseiga-logo.png", **options)
    when "Nijie"
      image_icon_tag("nijie-logo.png", **options)
    when "Patreon"
      image_icon_tag("patreon-logo.png", **options)
    when "pawoo.net"
      image_icon_tag("pawoo-logo.png", **options)
    when "Pixiv"
      image_icon_tag("pixiv-logo.png", **options)
    when "Pixiv Fanbox"
      image_icon_tag("pixiv-fanbox-logo.png", **options)
    when "Pixiv Sketch"
      image_icon_tag("pixiv-sketch-logo.png", **options)
    when "Privatter"
      image_icon_tag("privatter-logo.png", **options)
    when "Skeb"
      image_icon_tag("skeb-logo.png", **options)
    when "Tinami"
      image_icon_tag("tinami-logo.png", **options)
    when "Tumblr"
      image_icon_tag("tumblr-logo.png", **options)
    when "Twitter"
      image_icon_tag("twitter-logo.png", **options)
    when "Toranoana"
      image_icon_tag("toranoana-logo.png", **options)
    when "Weibo"
      image_icon_tag("weibo-logo.png", **options)
    when "Youtube"
      image_icon_tag("youtube-logo.png", **options)
    else
      globe_icon(**options)
    end
  end
end
