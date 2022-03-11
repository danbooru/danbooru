# frozen_string_literal: true

# Utility methods for working with tag categories (general, character,
# copyright, artist, meta).

module TagCategory
  module_function

  # Returns a hash mapping various tag categories to a numerical value.
  def mapping
    {
      "general" => 0,
      "gen" => 0,
      "artist" => 1,
      "art" => 1,
      "copyright" => 3,
      "copy" => 3,
      "co" => 3,
      "character" => 4,
      "char" => 4,
      "ch" => 4,
      "meta" => 5,
      "deprecated" => 6,
      "depre" => 6,
    }
  end

  # The order of tags in dropdown lists.
  def canonical_mapping
    {
      "Artist"      => 1,
      "Copyright"   => 3,
      "Character"   => 4,
      "General"     => 0,
      "Meta"        => 5,
      "Deprecated"  => 6,
    }
  end

  # Returns a hash mapping numerical category values to their string equivalent.
  def reverse_mapping
    {
      0 => "general",
      1 => "artist",
      3 => "copyright",
      4 => "character",
      5 => "meta",
      6 => "deprecated",
    }
  end

  def short_name_mapping
    {
      "art"   => "artist",
      "copy"  => "copyright",
      "char"  => "character",
      "gen"   => "general",
      "meta"  => "meta",
      "depre" => "deprecated",
    }
  end

  # Returns a hash mapping for titleization of a category name.
  # This is needed because pluralize thinks the plural of "deprecated" is "deprecateds"
  def title_map
    {
      "general" => "General",
      "character" => "Characters",
      "copyright" => "Copyrights",
      "artist" => "Artists",
      "meta" => "Meta",
      "deprecated" => "Deprecated",
    }
  end

  def categories
    %w[general character copyright artist meta deprecated]
  end

  def category_ids
    canonical_mapping.values
  end

  def short_name_list
    %w[art copy char gen meta depre]
  end

  # The order of tags on the post page tag list.
  def split_header_list
    %w[artist copyright character general deprecated meta]
  end

  # The order of tags inside the tag edit box, and on the comments page.
  def categorized_list
    %w[artist copyright character meta deprecated general]
  end

  # The order of tags in the related tag buttons.
  def related_button_list
    %w[general artist character copyright]
  end

  def category_ids_regex
    "[#{category_ids.join}]"
  end
end
