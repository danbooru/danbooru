# frozen_string_literal: true

module IconHelper
  # The list of sites we have a icon for. The logo for e.g. Pixiv is stored at public/images/pixiv-logo.png. This is a
  # hash mapping the site name to the logo filename.
  #
  # To add a new logo, just add the file to public/images. If the site name is irregular, update `site_name` inside
  # app/logical/source/url/null.rb to make the site name match the logo filename.
  SITE_ICONS = Rails.root.glob("public/images/*-logo.png").sort.to_h do |path|
    # ["pixiv", "pixiv-logo.png"]
    [path.basename.to_s.delete_suffix("-logo.png"), path.basename.to_s]
  end

  def svg_icon_tag(name, id = name, class: nil, **options)
    klass = binding.local_variable_get(:class)
    tag.svg(class: "icon svg-icon #{name}-icon #{klass}".strip, **options) do
      tag.use(fill: "currentColor", href: asset_pack_path("static/public/images/icons.svg") + "##{id}")
    end
  end

  def image_icon_tag(filename, class: nil, **options)
    klass = binding.local_variable_get(:class)
    image_pack_tag("static/public/images/#{filename}", class: "icon #{klass}", **options)
  end

  def upvote_icon(**options)
    svg_icon_tag("upvote", "arrow-alt-up", viewBox: "0 0 448 512", **options)
  end

  def downvote_icon(**options)
    svg_icon_tag("downvote", "arrow-alt-down", viewBox: "0 0 448 512", **options)
  end

  def sticky_icon(**options)
    svg_icon_tag("sticky", "solid-thumbtack", viewBox: "0 0 384 512", **options)
  end

  def unsticky_icon(**options)
    svg_icon_tag("unsticky", "regular-thumbtack", viewBox: "0 0 448 512", **options)
  end

  def lock_icon(**options)
    svg_icon_tag("lock", viewBox: "0 0 448 512", **options)
  end

  def delete_icon(**options)
    svg_icon_tag("delete", "trash", viewBox: "0 0 448 512", **options)
  end

  def undelete_icon(**options)
    svg_icon_tag("undelete", "trash-arrow-up", viewBox: "0 0 448 512", **options)
  end

  def private_icon(**options)
    svg_icon_tag("private", "hand", viewBox: "0 0 512 512", **options)
  end

  def menu_icon(**options)
    svg_icon_tag("menu", "bars", viewBox: "0 0 448 512", **options)
  end

  def close_icon(**options)
    svg_icon_tag("close", "xmark", viewBox: "0 0 320 512", **options)
  end

  def search_icon(**options)
    svg_icon_tag("search", "magnifying-glass", viewBox: "0 0 512 512", **options)
  end

  def bookmark_icon(**options)
    svg_icon_tag("bookmark", "bookmark", viewBox: "0 0 384 512", **options)
  end

  def empty_heart_icon(**options)
    svg_icon_tag("empty-heart", "regular-heart", viewBox: "0 0 512 512", **options)
  end

  def solid_heart_icon(**options)
    svg_icon_tag("solid-heart", "solid-heart", viewBox: "0 0 512 512", **options)
  end

  def comments_icon(**options)
    svg_icon_tag("comments", "comments", viewBox: "0 0 640 512", **options)
  end

  def spinner_icon(**options)
    klass = options.delete(:class)
    svg_icon_tag("spinner", class: "animate-spin #{klass}", viewBox: "0 0 512 512", **options)
  end

  def external_link_icon(**options)
    svg_icon_tag("external-link", "up-right-from-square", viewBox: "0 0 512 512", **options)
  end

  def checkmark_icon(**options)
    svg_icon_tag("checkmark", "solid-circle-check", viewBox: "0 0 512 512", **options)
  end

  def exclamation_icon(**options)
    svg_icon_tag("exclamation", "triangle-exclamation", viewBox: "0 0 512 512", **options)
  end

  def meh_icon(**options)
    svg_icon_tag("meh", "face-meh", viewBox: "0 0 512 512", **options)
  end

  def avatar_icon(**options)
    svg_icon_tag("avatar", "circle-user", viewBox: "0 0 512 512", **options)
  end

  def medal_icon(**options)
    svg_icon_tag("medal", viewBox: "0 0 512 512", **options)
  end

  def negative_icon(**options)
    svg_icon_tag("negative", "circle-xmark", viewBox: "0 0 512 512", **options)
  end

  def message_icon(**options)
    svg_icon_tag("message", "envelope", viewBox: "0 0 512 512", **options)
  end

  def gift_icon(**options)
    svg_icon_tag("gift", viewBox: "0 0 512 512", **options)
  end

  def feedback_icon(**options)
    svg_icon_tag("feedback", "file-signature", viewBox: "0 0 576 512", **options)
  end

  def promotion_icon(**options)
    svg_icon_tag("promotion", "user-plus", viewBox: "0 0 640 512", **options)
  end

  def ban_icon(**options)
    svg_icon_tag("ban", "user-slash", viewBox: "0 0 640 512", **options)
  end

  def chevron_left_icon(**options)
    svg_icon_tag("chevron-left", viewBox: "0 0 384 512", **options)
  end

  def chevron_right_icon(**options)
    svg_icon_tag("chevron-right", viewBox: "0 0 384 512", **options)
  end

  def chevron_down_icon(**options)
    svg_icon_tag("chevron-down", viewBox: "0 0 448 512", **options)
  end

  def ellipsis_icon(**options)
    svg_icon_tag("ellipsis", viewBox: "0 0 448 512", **options)
  end

  def edit_icon(**options)
    svg_icon_tag("edit", "solid-pen-to-square", viewBox: "0 0 512 512", **options)
  end

  def flag_icon(**options)
    svg_icon_tag("flag", viewBox: "0 0 448 512", **options)
  end

  def link_icon(**options)
    svg_icon_tag("link", viewBox: "0 0 640 512", **options)
  end

  def plus_icon(**options)
    svg_icon_tag("plus", viewBox: "0 0 448 512", **options)
  end

  def caret_down_icon(**options)
    svg_icon_tag("caret-down", viewBox: "0 0 320 512", **options)
  end

  def sound_icon(**options)
    svg_icon_tag("sound", "volume-high", viewBox: "0 0 640 512", **options)
  end

  def hashtag_icon(**options)
    svg_icon_tag("hashtag", viewBox: "0 0 448 512", **options)
  end

  def multiple_images_icon(**options)
    svg_icon_tag("multiple-images", "images", viewBox: "0 0 576 512", **options)
  end

  def grid_icon(**options)
    svg_icon_tag("grid", "table-cells", viewBox: "0 0 512 512", **options)
  end

  def list_icon(**options)
    svg_icon_tag("list", viewBox: "0 0 512 512", **options)
  end

  def table_icon(**options)
    svg_icon_tag("table", "table-list", viewBox: "0 0 512 512", **options)
  end

  def download_icon(**options)
    svg_icon_tag("download", viewBox: "0 0 512 512", **options)
  end

  def print_icon(**options)
    svg_icon_tag("print", viewBox: "0 0 512 512", **options)
  end

  def copy_icon(**options)
    svg_icon_tag("copy", viewBox: "0 0 448 512", **options)
  end

  def image_icon(**options)
    svg_icon_tag("image", viewBox: "0 0 512 512", **options)
  end

  def globe_icon(**options)
    svg_icon_tag("globe", viewBox: "0 0 512 512", **options)
  end

  def file_lines_icon(**options)
    svg_icon_tag("file-lines", viewBox: "0 0 384 512", **options)
  end

  def file_pen_icon(**options)
    svg_icon_tag("file-pen", viewBox: "0 0 576 512", **options)
  end

  def link_slash_icon(**options)
    svg_icon_tag("link-slash", viewBox: "0 0 640 512", **options)
  end

  def help_icon(**options)
    svg_icon_tag("circle-question", viewBox: "0 0 512 512", **options)
  end

  def info_icon(**options)
    svg_icon_tag("circle-info", viewBox: "0 0 512 512", **options)
  end

  def dock_top_icon(**options)
    svg_icon_tag("dock-top", viewBox: "0 0 1024 1024", **options)
  end

  def dock_right_icon(**options)
    svg_icon_tag("dock-right", viewBox: "0 0 1024 1024", **options)
  end

  def dock_bottom_icon(**options)
    svg_icon_tag("dock-bottom", viewBox: "0 0 1024 1024", **options)
  end

  def dock_left_icon(**options)
    svg_icon_tag("dock-left", viewBox: "0 0 1024 1024", **options)
  end

  def rotate_icon(**options)
    svg_icon_tag("rotate", viewBox: "0 0 512 512", **options)
  end

  def rotate_right_icon(**options)
    svg_icon_tag("rotate-right", viewBox: "0 0 512 512", **options)
  end

  def add_reaction_icon(**options)
    svg_icon_tag("add-reaction", viewBox: "0 0 24 24", **options)
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
    name = site_name.downcase.gsub(/[^a-z0-9.]/, "-")
    filename = SITE_ICONS[name]

    if filename
      image_icon_tag(filename, **options)
    else
      globe_icon(**options)
    end
  end
end
