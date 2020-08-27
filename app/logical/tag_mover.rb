class TagMover
  attr_reader :old_tag, :new_tag, :user

  def initialize(old_name, new_name, user: User.system)
    @old_tag = Tag.find_or_create_by_name(old_name)
    @new_tag = Tag.find_or_create_by_name(new_name)
    @user = user
  end

  def move!
    CurrentUser.scoped(user) do
      move_cosplay_tag!
      move_tag_category!
      move_artist!
      move_wiki!
      move_saved_searches!
      move_blacklists!
      rewrite_wiki_links!
      move_posts!
    end
  end

  def move_tag_category!
    if old_tag.general? && !new_tag.general?
      old_tag.update!(category: new_tag.category)
    elsif new_tag.general? && !old_tag.general?
      new_tag.update!(category: old_tag.category)
    end
  end

  def move_artist!
    return unless old_tag.artist? && old_artist.present? && !old_artist.is_deleted?

    if new_artist.nil?
      old_artist.update!(name: new_tag.name)
    else
      merge_artists!
    end
  end

  def move_wiki!
    return unless old_wiki.present? && !old_wiki.is_deleted?

    if new_wiki.nil?
      old_wiki.update!(title: new_tag.name)
    else
      merge_wikis!
    end
  end

  def move_posts!
    Post.raw_tag_match(old_tag.name).find_each do |post|
      post.lock!
      post.remove_tag(old_tag.name)
      post.add_tag(new_tag.name)
      post.save!
    end
  end

  def move_cosplay_tag!
    old_cosplay_tag = "#{old_tag.name}_(cosplay)"
    new_cosplay_tag = "#{new_tag.name}_(cosplay)"

    if Tag.nonempty.where(name: old_cosplay_tag).exists?
      TagMover.new(old_cosplay_tag, new_cosplay_tag).move!
    end
  end

  def move_saved_searches!
    SavedSearch.rewrite_queries!(old_tag.name, new_tag.name)
  end

  def move_blacklists!
    User.rewrite_blacklists!(old_tag.name, new_tag.name)
  end

  def rewrite_wiki_links!
    WikiPage.rewrite_wiki_links!(old_tag.name, new_tag.name)
  end

  def merge_artists!
    old_artist.lock!
    new_artist.lock!

    new_artist.other_names += old_artist.other_names
    new_artist.other_names += [old_artist.name]
    new_artist.group_name = old_artist.group_name unless new_artist.group_name.present?
    new_artist.url_string += "\n" + old_artist.url_string
    new_artist.is_deleted = false
    new_artist.save!

    old_artist.other_names = [new_artist.name]
    old_artist.group_name = ""
    old_artist.url_string = ""
    old_artist.is_deleted = true
    old_artist.save!
  end

  def merge_wikis!
    old_wiki.lock!
    new_wiki.lock!

    new_wiki.other_names += old_wiki.other_names
    new_wiki.is_deleted = false
    new_wiki.save!

    old_wiki.body = "This tag has been moved to [[#{new_wiki.title}]]."
    old_wiki.other_names = []
    old_wiki.is_deleted = true
    old_wiki.save!
  end

  def old_wiki
    old_tag.wiki_page
  end

  def new_wiki
    new_tag.wiki_page
  end

  def old_artist
    old_tag.artist
  end

  def new_artist
    new_tag.artist
  end
end
