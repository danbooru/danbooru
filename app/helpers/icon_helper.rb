module IconHelper
  def icon_tag(icon_class, class: nil, **options)
    klass = binding.local_variable_get(:class)
    tag.i(class: "icon #{icon_class} #{klass}", **options)
  end

  def upvote_icon(**options)
    icon_tag("far fa-thumbs-up", **options)
  end

  def downvote_icon(**options)
    icon_tag("far fa-thumbs-down", **options)
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

  def favorite_icon(**options)
    icon_tag("far fa-heart", **options)
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
end
