class TagCategory
  module Mappings
    # Returns a hash mapping various tag categories to a numerical value.
    def mapping
      @@mapping ||= Hash[
          Danbooru.config.full_tag_config_info.map {|k,v|  v["extra"].map {|y| [y,v["category"]]}}
          .reduce([],:+)]
        .update(Hash[Danbooru.config.full_tag_config_info.map {|k,v|  [v["short"],v["category"]]}])
        .update( Hash[Danbooru.config.full_tag_config_info.map {|k,v| [k,v["category"]]}])
    end

    # Returns a hash mapping more suited for views
    def canonical_mapping
      @@canonical_mapping ||= Hash[Danbooru.config.full_tag_config_info.map {|k,v| [k.capitalize,v["category"]]}]
    end

    # Returns a hash mapping numerical category values to their string equivalent.
    def reverse_mapping
      @@reverse_mapping ||= Hash[Danbooru.config.full_tag_config_info.map {|k,v| [v["category"],k]}]
    end

    # Returns a hash mapping for the short name usage in metatags
    def short_name_mapping
      @@short_name_mapping ||= Hash[Danbooru.config.full_tag_config_info.map {|k,v| [v["short"],k]}]
    end

    # Returns a hash mapping for humanized_essential_tag_string (models/post.rb)
    def humanized_mapping
      @@humanized_mapping ||= Hash[Danbooru.config.full_tag_config_info.map {|k,v| [k,v["humanized"]]}]
    end

    # Returns a hash mapping for split_tag_list_html (presenters/tag_set_presenter.rb)
    def header_mapping
      @@header_mapping ||= Hash[Danbooru.config.full_tag_config_info.map {|k,v| [k,v["header"]]}]
    end

    # Returns a hash mapping for related tag buttons (javascripts/related_tag.js)
    def related_button_mapping
      @@related_button_mapping ||= Hash[Danbooru.config.full_tag_config_info.map {|k,v| [k,v["relatedbutton"]]}]
    end
  end

  module Lists
    def categories
      @@categories ||= Danbooru.config.full_tag_config_info.keys
    end

    def category_ids
      @@category_ids ||= canonical_mapping.values
    end

    def short_name_list
      @@short_name_list ||= short_name_mapping.keys
    end

    def humanized_list
      Danbooru.config.humanized_tag_category_list
    end

    def split_header_list
      Danbooru.config.split_tag_header_list
    end

    def categorized_list
      Danbooru.config.categorized_tag_list
    end

    def related_button_list
      Danbooru.config.related_tag_button_list
    end
  end

  module Regexes
    def short_name_regex
      @@short_name_regex ||= short_name_list.join("|")
    end
  end

  extend Mappings
  extend Lists
  extend Regexes
end
