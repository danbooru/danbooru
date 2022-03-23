# frozen_string_literal: true

module IconHelper
  def icon_tag(icon_class, class: nil, **options)
    klass = binding.local_variable_get(:class)
    tag.i(class: "icon #{icon_class} #{klass}", **options)
  end

  def svg_icon_tag(type, path, class: nil, viewbox: "0 0 448 512", **options)
    klass = binding.local_variable_get(:class)
    tag.svg(class: "icon svg-icon #{type} #{klass}", role: "img", xmlns: "http://www.w3.org/2000/svg", viewBox: viewbox, **options) do
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

  def unsticky_icon(**options)
    svg_icon_tag("unsticky-icon", "M306.5 186.6l-5.7-42.6H328c13.2 0 24-10.8 24-24V24c0-13.2-10.8-24-24-24H56C42.8 0 32 10.8 32 24v96c0 13.2 10.8 24 24 24h27.2l-5.7 42.6C29.6 219.4 0 270.7 0 328c0 13.2 10.8 24 24 24h144v104c0 .9.1 1.7.4 2.5l16 48c2.4 7.3 12.8 7.3 15.2 0l16-48c.3-.8.4-1.7.4-2.5V352h144c13.2 0 24-10.8 24-24 0-57.3-29.6-108.6-77.5-141.4zM50.5 304c8.3-38.5 35.6-70 71.5-87.8L138 96H80V48h224v48h-58l16 120.2c35.8 17.8 63.2 49.4 71.5 87.8z", **options)
  end

  def lock_icon(**options)
    icon_tag("fas fa-lock", **options)
  end

  def delete_icon(**options)
    icon_tag("fas fa-trash-alt", **options)
  end

  def undelete_icon(**options)
    icon_tag("fas fa-trash-restore-alt", **options)
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
    svg_icon_tag("spinner-icon animate-spin", "M304 48C304 74.51 282.5 96 256 96C229.5 96 208 74.51 208 48C208 21.49 229.5 0 256 0C282.5 0 304 21.49 304 48zM304 464C304 490.5 282.5 512 256 512C229.5 512 208 490.5 208 464C208 437.5 229.5 416 256 416C282.5 416 304 437.5 304 464zM0 256C0 229.5 21.49 208 48 208C74.51 208 96 229.5 96 256C96 282.5 74.51 304 48 304C21.49 304 0 282.5 0 256zM512 256C512 282.5 490.5 304 464 304C437.5 304 416 282.5 416 256C416 229.5 437.5 208 464 208C490.5 208 512 229.5 512 256zM74.98 437C56.23 418.3 56.23 387.9 74.98 369.1C93.73 350.4 124.1 350.4 142.9 369.1C161.6 387.9 161.6 418.3 142.9 437C124.1 455.8 93.73 455.8 74.98 437V437zM142.9 142.9C124.1 161.6 93.73 161.6 74.98 142.9C56.24 124.1 56.24 93.73 74.98 74.98C93.73 56.23 124.1 56.23 142.9 74.98C161.6 93.73 161.6 124.1 142.9 142.9zM369.1 369.1C387.9 350.4 418.3 350.4 437 369.1C455.8 387.9 455.8 418.3 437 437C418.3 455.8 387.9 455.8 369.1 437C350.4 418.3 350.4 387.9 369.1 369.1V369.1z", viewbox: "0 0 512 512", **options)
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

  def caret_down_icon(**options)
    svg_icon_tag("caret-down-icon", "M310.6 246.6l-127.1 128C176.4 380.9 168.2 384 160 384s-16.38-3.125-22.63-9.375l-127.1-128C.2244 237.5-2.516 223.7 2.438 211.8S19.07 192 32 192h255.1c12.94 0 24.62 7.781 29.58 19.75S319.8 237.5 310.6 246.6z", viewbox: "0 0 320 512", **options)
  end

  # https://fontawesome.com/v6.0/icons/volume-high
  def sound_icon(**options)
    svg_icon_tag("sound-icon", "M412.6 182c-10.28-8.334-25.41-6.867-33.75 3.402c-8.406 10.24-6.906 25.35 3.375 33.74C393.5 228.4 400 241.8 400 255.1c0 14.17-6.5 27.59-17.81 36.83c-10.28 8.396-11.78 23.5-3.375 33.74c4.719 5.806 11.62 8.802 18.56 8.802c5.344 0 10.75-1.779 15.19-5.399C435.1 311.5 448 284.6 448 255.1S435.1 200.4 412.6 182zM473.1 108.2c-10.22-8.334-25.34-6.898-33.78 3.34c-8.406 10.24-6.906 25.35 3.344 33.74C476.6 172.1 496 213.3 496 255.1s-19.44 82.1-53.31 110.7c-10.25 8.396-11.75 23.5-3.344 33.74c4.75 5.775 11.62 8.771 18.56 8.771c5.375 0 10.75-1.779 15.22-5.431C518.2 366.9 544 313 544 255.1S518.2 145 473.1 108.2zM534.4 33.4c-10.22-8.334-25.34-6.867-33.78 3.34c-8.406 10.24-6.906 25.35 3.344 33.74C559.9 116.3 592 183.9 592 255.1s-32.09 139.7-88.06 185.5c-10.25 8.396-11.75 23.5-3.344 33.74C505.3 481 512.2 484 519.2 484c5.375 0 10.75-1.779 15.22-5.431C601.5 423.6 640 342.5 640 255.1S601.5 88.34 534.4 33.4zM301.2 34.98c-11.5-5.181-25.01-3.076-34.43 5.29L131.8 160.1H48c-26.51 0-48 21.48-48 47.96v95.92c0 26.48 21.49 47.96 48 47.96h83.84l134.9 119.8C272.7 477 280.3 479.8 288 479.8c4.438 0 8.959-.9314 13.16-2.835C312.7 471.8 320 460.4 320 447.9V64.12C320 51.55 312.7 40.13 301.2 34.98z", viewbox: "0 0 640 512", **options)
  end

  def hashtag_icon(**options)
    svg_icon_tag("hashtag-icon", "M416 127.1h-58.23l9.789-58.74c2.906-17.44-8.875-33.92-26.3-36.83c-17.53-2.875-33.92 8.891-36.83 26.3L292.9 127.1H197.8l9.789-58.74c2.906-17.44-8.875-33.92-26.3-36.83c-17.53-2.875-33.92 8.891-36.83 26.3L132.9 127.1H64c-17.67 0-32 14.33-32 32C32 177.7 46.33 191.1 64 191.1h58.23l-21.33 128H32c-17.67 0-32 14.33-32 32c0 17.67 14.33 31.1 32 31.1h58.23l-9.789 58.74c-2.906 17.44 8.875 33.92 26.3 36.83C108.5 479.9 110.3 480 112 480c15.36 0 28.92-11.09 31.53-26.73l11.54-69.27h95.12l-9.789 58.74c-2.906 17.44 8.875 33.92 26.3 36.83C268.5 479.9 270.3 480 272 480c15.36 0 28.92-11.09 31.53-26.73l11.54-69.27H384c17.67 0 32-14.33 32-31.1c0-17.67-14.33-32-32-32h-58.23l21.33-128H416c17.67 0 32-14.32 32-31.1C448 142.3 433.7 127.1 416 127.1zM260.9 319.1H165.8L187.1 191.1h95.12L260.9 319.1z", viewbox: "0 0 448 512", **options)
  end

  def multiple_images_icon(**options)
    svg_icon_tag("multiple-images-icon", "M8,3 C8.55228475,3 9,3.44771525 9,4 L9,9 C9,9.55228475 8.55228475,10 8,10 L3,10 C2.44771525,10 2,9.55228475 2,9 L6,9 C7.1045695,9 8,8.1045695 8,7 L8,3 Z M1,1 L6,1 C6.55228475,1 7,1.44771525 7,2 L7,7 C7,7.55228475 6.55228475,8 6,8 L1,8 C0.44771525,8 0,7.55228475 0,7 L0,2 C0,1.44771525 0.44771525,1 1,1 Z", viewbox: "0 0 9 10", **options)
  end

  def grid_icon(**options)
    svg_icon_tag("grid-icon", "M448 32C483.3 32 512 60.65 512 96V416C512 451.3 483.3 480 448 480H64C28.65 480 0 451.3 0 416V96C0 60.65 28.65 32 64 32H448zM152 96H64V160H152V96zM208 160H296V96H208V160zM448 96H360V160H448V96zM64 288H152V224H64V288zM296 224H208V288H296V224zM360 288H448V224H360V288zM152 352H64V416H152V352zM208 416H296V352H208V416zM448 352H360V416H448V352z", viewbox: "0 0 512 512", **options)
  end

  def list_icon(**options)
    svg_icon_tag("list-icon", "M88 48C101.3 48 112 58.75 112 72V120C112 133.3 101.3 144 88 144H40C26.75 144 16 133.3 16 120V72C16 58.75 26.75 48 40 48H88zM480 64C497.7 64 512 78.33 512 96C512 113.7 497.7 128 480 128H192C174.3 128 160 113.7 160 96C160 78.33 174.3 64 192 64H480zM480 224C497.7 224 512 238.3 512 256C512 273.7 497.7 288 480 288H192C174.3 288 160 273.7 160 256C160 238.3 174.3 224 192 224H480zM480 384C497.7 384 512 398.3 512 416C512 433.7 497.7 448 480 448H192C174.3 448 160 433.7 160 416C160 398.3 174.3 384 192 384H480zM16 232C16 218.7 26.75 208 40 208H88C101.3 208 112 218.7 112 232V280C112 293.3 101.3 304 88 304H40C26.75 304 16 293.3 16 280V232zM88 368C101.3 368 112 378.7 112 392V440C112 453.3 101.3 464 88 464H40C26.75 464 16 453.3 16 440V392C16 378.7 26.75 368 40 368H88z", viewbox: "0 0 512 512", **options)
  end

  def table_icon(**options)
    svg_icon_tag("table-icon", "M0 96C0 60.65 28.65 32 64 32H448C483.3 32 512 60.65 512 96V416C512 451.3 483.3 480 448 480H64C28.65 480 0 451.3 0 416V96zM64 160H128V96H64V160zM448 96H192V160H448V96zM64 288H128V224H64V288zM448 224H192V288H448V224zM64 416H128V352H64V416zM448 352H192V416H448V352z", viewbox: "0 0 512 512", **options)
  end

  def image_icon(**options)
    svg_icon_tag("image-icon", "M447.1 32h-384C28.64 32-.0091 60.65-.0091 96v320c0 35.35 28.65 64 63.1 64h384c35.35 0 64-28.65 64-64V96C511.1 60.65 483.3 32 447.1 32zM111.1 96c26.51 0 48 21.49 48 48S138.5 192 111.1 192s-48-21.49-48-48S85.48 96 111.1 96zM446.1 407.6C443.3 412.8 437.9 416 432 416H82.01c-6.021 0-11.53-3.379-14.26-8.75c-2.73-5.367-2.215-11.81 1.334-16.68l70-96C142.1 290.4 146.9 288 152 288s9.916 2.441 12.93 6.574l32.46 44.51l93.3-139.1C293.7 194.7 298.7 192 304 192s10.35 2.672 13.31 7.125l128 192C448.6 396 448.9 402.3 446.1 407.6z", viewbox: "0 0 512 512", **options)
  end

  # https://fontawesome.com/icons/globe
  def globe_icon(**options)
    svg_icon_tag("globe-icon", "M352 256C352 278.2 350.8 299.6 348.7 320H163.3C161.2 299.6 159.1 278.2 159.1 256C159.1 233.8 161.2 212.4 163.3 192H348.7C350.8 212.4 352 233.8 352 256zM503.9 192C509.2 212.5 512 233.9 512 256C512 278.1 509.2 299.5 503.9 320H380.8C382.9 299.4 384 277.1 384 256C384 234 382.9 212.6 380.8 192H503.9zM493.4 160H376.7C366.7 96.14 346.9 42.62 321.4 8.442C399.8 29.09 463.4 85.94 493.4 160zM344.3 160H167.7C173.8 123.6 183.2 91.38 194.7 65.35C205.2 41.74 216.9 24.61 228.2 13.81C239.4 3.178 248.7 0 256 0C263.3 0 272.6 3.178 283.8 13.81C295.1 24.61 306.8 41.74 317.3 65.35C328.8 91.38 338.2 123.6 344.3 160H344.3zM18.61 160C48.59 85.94 112.2 29.09 190.6 8.442C165.1 42.62 145.3 96.14 135.3 160H18.61zM131.2 192C129.1 212.6 127.1 234 127.1 256C127.1 277.1 129.1 299.4 131.2 320H8.065C2.8 299.5 0 278.1 0 256C0 233.9 2.8 212.5 8.065 192H131.2zM194.7 446.6C183.2 420.6 173.8 388.4 167.7 352H344.3C338.2 388.4 328.8 420.6 317.3 446.6C306.8 470.3 295.1 487.4 283.8 498.2C272.6 508.8 263.3 512 255.1 512C248.7 512 239.4 508.8 228.2 498.2C216.9 487.4 205.2 470.3 194.7 446.6H194.7zM190.6 503.6C112.2 482.9 48.59 426.1 18.61 352H135.3C145.3 415.9 165.1 469.4 190.6 503.6V503.6zM321.4 503.6C346.9 469.4 366.7 415.9 376.7 352H493.4C463.4 426.1 399.8 482.9 321.4 503.6V503.6z", viewbox: "0 0 512 512", **options)
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
    when "Amazon"
      image_icon_tag("amazon-logo.png", **options)
    when "Ameblo"
      image_icon_tag("ameblo-logo.png", **options)
    when "ArtStation"
      image_icon_tag("artstation-logo.png", **options)
    when "Ask.fm"
      image_icon_tag("ask-fm-logo.png", **options)
    when "BCY"
      image_icon_tag("bcy-logo.png", **options)
    when "Biglobe"
      image_icon_tag("biglobe-logo.png", **options)
    when "Booth.pm"
      image_icon_tag("booth-pm-logo.png", **options)
    when "Circle.ms"
      image_icon_tag("circle-ms-logo.png", **options)
    when "Deviant Art"
      image_icon_tag("deviantart-logo.png", **options)
    when "DLSite"
      image_icon_tag("dlsite-logo.png", **options)
    when "Doujinshi.org"
      image_icon_tag("doujinshi-org-logo.png", **options)
    when "Erogamescape"
      image_icon_tag("erogamescape-logo.png", **options)
    when "Facebook"
      image_icon_tag("facebook-logo.png", **options)
    when "Fantia"
      image_icon_tag("fantia-logo.png", **options)
    when "FC2"
      image_icon_tag("fc2-logo.png", **options)
    when "Foundation"
      image_icon_tag("foundation-logo.png", **options)
    when "Geocities"
      image_icon_tag("geocities-logo.png", **options)
    when "Google"
      image_icon_tag("google-logo.png", **options)
    when "Gumroad"
      image_icon_tag("gumroad-logo.png", **options)
    when "Hentai Foundry"
      image_icon_tag("hentai-foundry-logo.png", **options)
    when "Infoseek"
      image_icon_tag("infoseek-logo.png", **options)
    when "Instagram"
      image_icon_tag("instagram-logo.png", **options)
    when "Ko-fi"
      image_icon_tag("ko-fi-logo.png", **options)
    when "Livedoor"
      image_icon_tag("livedoor-logo.png", **options)
    when "Lofter"
      image_icon_tag("lofter-logo.png", **options)
    when "Mangaupdates"
      image_icon_tag("mangaupdates-logo.png", **options)
    when "Marshmallow Qa"
      image_icon_tag("marshmallow-qa-logo.png", **options)
    when "Mastodon", "Mstdn" # https://mastodon.cloud, https://mstdn.jp
      image_icon_tag("mastodon-logo.png", **options)
    when "Melonbooks"
      image_icon_tag("melonbooks-logo.png", **options)
    when "Mihuashi"
      image_icon_tag("mihuashi-logo.png", **options)
    when "Mixi.jp"
      image_icon_tag("mixi-jp-logo.png", **options)
    when "Naver"
      image_icon_tag("naver-logo.png", **options)
    when "Newgrounds"
      image_icon_tag("newgrounds-logo.png", **options)
    when "Nico Seiga"
      image_icon_tag("nicoseiga-logo.png", **options)
    when "Nijie"
      image_icon_tag("nijie-logo.png", **options)
    when "Patreon"
      image_icon_tag("patreon-logo.png", **options)
    when "Pawoo"
      image_icon_tag("pawoo-logo.png", **options)
    when "Photozou"
      image_icon_tag("photozou-logo.png", **options)
    when "Piapro.jp"
      image_icon_tag("piapro-jp-logo.png", **options)
    when "Picarto"
      image_icon_tag("picarto-logo.png", **options)
    when "Pixiv"
      image_icon_tag("pixiv-logo.png", **options)
    when "Fanbox"
      image_icon_tag("pixiv-fanbox-logo.png", **options)
    when "Pixiv Sketch"
      image_icon_tag("pixiv-sketch-logo.png", **options)
    when "Plurk"
      image_icon_tag("plurk-logo.png", **options)
    when "Privatter"
      image_icon_tag("privatter-logo.png", **options)
    when "Reddit"
      image_icon_tag("reddit-logo.png", **options)
    when "Sakura.ne.jp"
      image_icon_tag("sakura-ne-jp-logo.png", **options)
    when "Stickam"
      image_icon_tag("stickam-logo.png", **options)
    when "Skeb"
      image_icon_tag("skeb-logo.png", **options)
    when "Skima"
      image_icon_tag("skima-logo.png", **options)
    when "Theinterviews"
      image_icon_tag("the-interviews-logo.png", **options)
    when "Tinami"
      image_icon_tag("tinami-logo.png", **options)
    when "Tumblr"
      image_icon_tag("tumblr-logo.png", **options)
    when "Twitter"
      image_icon_tag("twitter-logo.png", **options)
    when "Toranoana"
      image_icon_tag("toranoana-logo.png", **options)
    when "Twipple"
      image_icon_tag("twipple-logo.png", **options)
    when "Twitch"
      image_icon_tag("twitch-logo.png", **options)
    when "Twitcasting"
      image_icon_tag("twitcasting-logo.png", **options)
    when "TwitPic"
      image_icon_tag("twitpic-logo.png", **options)
    when "Twpf"
      image_icon_tag("twpf-logo.png", **options)
    when "Ustream"
      image_icon_tag("ustream-logo.png", **options)
    when "Weibo"
      image_icon_tag("weibo-logo.png", **options)
    when "Wikipedia"
      image_icon_tag("wikipedia-logo.png", **options)
    when "Yfrog"
      image_icon_tag("yfrog-logo.png", **options)
    when "Youtube"
      image_icon_tag("youtube-logo.png", **options)
    else
      globe_icon(**options)
    end
  end
end
