module ArtistsHelper
  def artist_alias_and_implication_list(artist)
    consequent_tag_aliases = TagAlias.where("status in ('active', 'processing') and consequent_name = ?", artist.name)
    antecedent_tag_alias = TagAlias.where("status in ('active', 'processing') and antecedent_name = ?", artist.name).first
    consequent_tag_implications = TagImplication.where("status in ('active', 'processing') and consequent_name = ?", artist.name)
    antecedent_tag_implications = TagImplication.where("status in ('active', 'processing') and antecedent_name = ?", artist.name)

    alias_and_implication_list(antecedent_tag_alias, consequent_tag_aliases, antecedent_tag_implications, consequent_tag_implications)
  end

  def link_to_artist(name)
    artist = Artist.find_by_name(name)

    if artist
      link_to(artist.name, artist_path(artist))
    else
      link_to(name, new_artist_path(:name => name)) + " " + content_tag("span", "*", :class => "new-artist", :title => "No artist with this name currently exists.")
    end
  end

  def link_to_artists(names)
    names.map do |name|
      link_to_artist(name)
    end.join(", ").html_safe
  end
end
