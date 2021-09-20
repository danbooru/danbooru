# Rename a tag and move everything associated with it. Used when renaming or
# aliasing a tag in a bulk update request. Moves everything associated with the
# tag, including aliases, implications, *_(cosplay) and *_(style) tags, artist
# and wiki pages, saved searches, blacklists, and retags the posts themselves.
class TagMover
  attr_reader :old_tag, :new_tag, :user

  # Initalize a tag move.
  # @param old_name [String] the name of the tag to move
  # @param new_name [String] the new tag name
  # @param user [User] the user to credit for all edits in moving the tag
  def initialize(old_name, new_name, user: User.system)
    @old_tag = Tag.find_or_create_by_name(old_name)
    @new_tag = Tag.find_or_create_by_name(new_name)
    @user = user
  end

  # Perform the tag move.
  def move!
    CurrentUser.scoped(user) do
      move_tag_category!
      move_aliases!
      move_implications!
      move_cosplay_tag!
      move_style_tag!
      move_artist!
      move_wiki!
      move_saved_searches!
      move_blacklists!
      rewrite_wiki_links!
      move_posts!
    end
  end

  # Sync the category of both tags, if one is a general tag and the other is non-general.
  def move_tag_category!
    if old_tag.general? && !new_tag.general?
      old_tag.update!(category: new_tag.category)
    elsif new_tag.general? && !old_tag.general?
      new_tag.update!(category: old_tag.category)
    end
  end

  # Move the artist entry from the old tag to the new tag, merging it into the
  # new tag's artist entry if it already has an artist entry.
  def move_artist!
    return unless old_tag.artist? && old_artist.present? && !old_artist.is_deleted?

    if new_artist.nil?
      old_artist.name = new_tag.name
      old_artist.other_names += [old_tag.name]
      old_artist.save!
    else
      merge_artists!
    end
  end

  # Move the wiki from the old tag to the new tag, merging it into the new tag's
  # wiki if it already has a wiki.
  def move_wiki!
    return unless old_wiki.present? && !old_wiki.is_deleted?

    if new_wiki.nil?
      old_wiki.update!(title: new_tag.name)
    else
      merge_wikis!
    end
  end

  # Retag the posts from the old tag to the new tag.
  def move_posts!
    Post.raw_tag_match(old_tag.name).reorder(nil).parallel_each do |post|
      post.lock!
      post.remove_tag(old_tag.name)
      post.add_tag(new_tag.name)
      post.save!
    end
  end

  # Transfer any aliases pointing to the old tag to point to the new tag.
  def move_aliases!
    old_tag.consequent_aliases.each do |tag_alias|
      tag_alias.update!(consequent_name: new_tag.name)
    end
  end

  # Transfer any implications from the old tag to the new tag.
  def move_implications!
    old_tag.antecedent_implications.each do |tag_implication|
      tag_implication.update!(antecedent_name: new_tag.name)
    end

    old_tag.consequent_implications.each do |tag_implication|
      tag_implication.update!(consequent_name: new_tag.name)
    end
  end

  # Move the character's *_(cosplay) tag if it exists.
  def move_cosplay_tag!
    old_cosplay_tag = "#{old_tag.name}_(cosplay)"
    new_cosplay_tag = "#{new_tag.name}_(cosplay)"

    if Tag.nonempty.exists?(name: old_cosplay_tag)
      TagMover.new(old_cosplay_tag, new_cosplay_tag).move!
    end
  end

  # Move the artist's *_(style) tag if it exists.
  def move_style_tag!
    old_style_tag = "#{old_tag.name}_(style)"
    new_style_tag = "#{new_tag.name}_(style)"

    if old_tag.artist? && Tag.nonempty.exists?(name: old_style_tag)
      TagMover.new(old_style_tag, new_style_tag).move!
    end
  end

  # Update all saved searches to use the new tag.
  def move_saved_searches!
    SavedSearch.rewrite_queries!(old_tag.name, new_tag.name)
  end

  # Update all blacklists to use the new tag.
  def move_blacklists!
    User.rewrite_blacklists!(old_tag.name, new_tag.name)
  end

  # Update any wiki pages linking to the old tag, to link to the new tag.
  def rewrite_wiki_links!
    WikiPage.rewrite_wiki_links!(old_tag.name, new_tag.name)
  end

  # Merge two artist entries, copying everything from the old entry to the new
  # one. Duplicate information will be automatically stripped when the artist
  # is saved.
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

  # Merge the other names from both wikis. Transfer the body from the old wiki
  # to the new wiki if the new wiki has an empty body. Then mark the old wiki
  # as deleted.
  def merge_wikis!
    old_wiki.lock!
    new_wiki.lock!

    new_wiki.other_names += old_wiki.other_names
    new_wiki.is_deleted = false
    new_wiki.body = old_wiki.body if new_wiki.body.blank? && old_wiki.body.present?
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
