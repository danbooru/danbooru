require 'dtext'

module ApplicationHelper
  def listing_type(*fields, member_check: true, types: [:revert, :standard])
    (fields.reduce(false) { |acc, field| acc || params.dig(:search, field).present? } && (!member_check || CurrentUser.is_member?) ? types[0] : types[1])
  end

  def diff_list_html(new, old, latest, ul_class: ["diff-list"], li_class: [])
    diff = SetDiff.new(new, old, latest)
    render "diff_list", diff: diff, ul_class: ul_class, li_class: li_class
  end

  def diff_name_html(this_name, prev_name)
    pattern = Regexp.new('.')
    DiffBuilder.new(this_name, prev_name, pattern).build
  end

  def diff_body_html(record, previous, field)
    return h(record[field]).gsub(/\r?\n/, '<span class="paragraph-mark">¶</span><br>').html_safe if previous.blank?

    pattern = Regexp.new('(?:<.+?>)|(?:\w+)|(?:[ \t]+)|(?:\r?\n)|(?:.+?)')
    DiffBuilder.new(record[field], previous[field], pattern).build
  end

  def status_diff_html(record)
    previous = record.previous

    return "New" if previous.blank?

    statuses = []
    record.class.status_fields.each do |field, status|
      if record.has_attribute?(field)
        statuses += [status] if record[field] != previous[field]
      else
        statuses += [status] if record.send(field)
      end
    end
    statuses.join("<br>").html_safe
  end

  def wordbreakify(string)
    lines = string.scan(/.{1,10}/)
    wordbreaked_string = lines.map {|str| h(str)}.join("<wbr>")
    raw(wordbreaked_string)
  end

  def nav_link_to(text, url, **options)
    klass = options.delete(:class)

    if nav_link_match(params[:controller], url)
      klass = "#{klass} current"
    end

    li_link_to(text, url, id_prefix: "nav-", class: klass, **options)
  end

  def subnav_link_to(text, url, **options)
    li_link_to(text, url, id_prefix: "subnav-", **options)
  end

  def li_link_to(text, url, id_prefix: "", **options)
    klass = options.delete(:class)
    id = id_prefix + text.downcase.gsub(/[^a-z ]/, "").parameterize
    tag.li(link_to(text, url, id: "#{id}-link", **options), id: id, class: klass)
  end

  def format_text(text, **options)
    raw DText.format_text(text, **options)
  end

  def strip_dtext(text)
    DText.strip_dtext(text)
  end

  def error_messages_for(instance_name)
    instance = instance_variable_get("@#{instance_name}")

    if instance&.errors&.any?
      %{<div class="error-messages ui-state-error ui-corner-all"><strong>Error</strong>: #{instance.__send__(:errors).full_messages.join(", ")}</div>}.html_safe
    else
      ""
    end
  end

  def time_tag(content, time, **options)
    datetime = time.strftime("%Y-%m-%dT%H:%M%:z")

    tag.time content || datetime, datetime: datetime, title: time.to_formatted_s, **options
  end

  def humanized_duration(from, to)
    if to - from > 10.years
      duration = "forever"
    else
      duration = distance_of_time_in_words(from, to)
    end

    datetime = from.iso8601 + "/" + to.iso8601
    title = "#{from.strftime("%Y-%m-%d %H:%M")} to #{to.strftime("%Y-%m-%d %H:%M")}"

    raw content_tag(:time, duration, datetime: datetime, title: title)
  end

  def time_ago_in_words_tagged(time, compact: false)
    if time.past?
      if compact
        text = time_ago_in_words(time)
        text = text.gsub(/almost|about|over/, "").strip
        text = text.gsub(/less than a/, "<1")
        text = text.gsub(/ minutes?/, "m")
        text = text.gsub(/ hours?/, "h")
        text = text.gsub(/ days?/, "d")
        text = text.gsub(/ months?/, "mo")
        text = text.gsub(/ years?/, "y")
        klass = "compact-timestamp"
      else
        text = time_ago_in_words(time) + " ago"
        klass = ""
      end

      time_tag(text, time, class: klass)
    else
      time_tag("in " + distance_of_time_in_words(Time.now, time), time)
    end
  end

  def compact_time(time)
    time_tag(time.strftime("%Y-%m-%d %H:%M"), time)
  end

  def external_link_to(url, text = url, truncate: nil, strip: false, **link_options)
    text = text.gsub(%r!\Ahttps?://!i, "") if strip == :scheme
    text = text.gsub(%r!\Ahttps?://(?:www\.)?!i, "") if strip == :subdomain
    text = text.truncate(truncate) if truncate

    if url =~ %r!\Ahttps?://!i
      link_to text, url, rel: "external noreferrer nofollow", **link_options
    else
      url
    end
  end

  def link_to_ip(ip)
    link_to ip, ip_addresses_path(search: { ip_addr: ip, group_by: "user" })
  end

  def link_to_search(search)
    link_to search, posts_path(tags: search)
  end

  def link_to_wiki(text, title = text, **options)
    title = "~#{title}" if title =~ /\A\d+\z/
    link_to text, wiki_page_path(title), class: "wiki-link", **options
  end

  def link_to_wikis(*wiki_titles, **options)
    links = wiki_titles.map do |title|
      link_to_wiki title.tr("_", " "), title
    end

    to_sentence(links, **options)
  end

  def link_to_user(user, options = {})
    return "anonymous" if user.blank?

    user_class = "user-#{user.level_string.downcase}"
    user_class += " user-post-approver" if user.can_approve_posts?
    user_class += " user-post-uploader" if user.can_upload_free?
    user_class += " user-banned" if user.is_banned?
    user_class += " with-style" if CurrentUser.user.style_usernames?
    if options[:raw_name]
      name = user.name
    else
      name = user.pretty_name
    end
    link_to(name, user_path(user), :class => user_class)
  end

  def mod_link_to_user(user, positive_or_negative)
    html = ""
    html << link_to_user(user)

    if positive_or_negative == :positive
      html << " [" + link_to("+", new_user_feedback_path(:user_feedback => {:category => "positive", :user_id => user.id})) + "]"

      unless user.is_gold?
        html << " [" + link_to("promote", edit_admin_user_path(user)) + "]"
      end
    else
      html << " [" + link_to("&ndash;".html_safe, new_user_feedback_path(:user_feedback => {:category => "negative", :user_id => user.id})) + "]"
    end

    html.html_safe
  end

  def embed_wiki(title, **options)
    wiki = WikiPage.find_by(title: title)
    text = format_text(wiki&.body)
    tag.div(text, class: "prose", **options)
  end

  def dtext_field(object, name, options = {})
    options[:name] ||= name.capitalize
    options[:input_id] ||= "#{object}_#{name}"
    options[:input_name] ||= "#{object}[#{name}]"
    options[:value] ||= instance_variable_get("@#{object}").try(name)
    options[:preview_id] ||= "dtext-preview"
    options[:classes] ||= ""
    options[:type] ||= "text"

    render "dtext/form", options
  end

  def dtext_preview_button(object, name, input_id: "#{object}_#{name}", preview_id: "dtext-preview")
    tag.input value: "Preview", type: "button", class: "dtext-preview-button", "data-input-id": input_id, "data-preview-id": preview_id
  end

  def quick_search_form_for(attribute, url, name, autocomplete: nil, redirect: false, &block)
    tag.li do
      search_form_for(url, classes: "quick-search-form one-line-form") do |f|
        out  = f.input attribute, label: false, placeholder: "Search #{name}", input_html: { id: nil, "data-autocomplete": autocomplete }
        out += tag.input type: :hidden, name: :redirect, value: redirect
        out += capture { yield f } if block_given?
        out
      end
    end
  end

  def search_form_for(url, classes: "inline-form", method: :get, &block)
    defaults = { required: false }
    html_options = { autocomplete: "off", class: "search-form #{classes}" }

    simple_form_for(:search, method: method, url: url, defaults: defaults, html: html_options, &block)
  end

  def edit_form_for(model, **options, &block)
    options[:html] = { autocomplete: "off", **options[:html].to_h }
    options[:authenticity_token] = true if options[:remote] == true
    simple_form_for(model, **options, &block)
  end

  def table_for(*args, **options, &block)
    table = TableBuilder.new(*args, **options, &block)
    render "table_builder/table", table: table
  end

  def body_attributes(user, params, current_item = nil)
    current_user_data_attributes = data_attributes_for(user, "current-user", current_user_attributes)

    if current_item.present? && current_item.respond_to?(:html_data_attributes) && current_item.respond_to?(:model_name)
      model_name = current_item.model_name.singular.dasherize
      model_attributes = current_item.html_data_attributes
      current_item_data_attributes = data_attributes_for(current_item, model_name, model_attributes)
    end

    controller_param = params[:controller].parameterize.dasherize
    action_param = params[:action].parameterize.dasherize

    {
      lang: "en",
      class: "c-#{controller_param} a-#{action_param}",
      data: {
        controller: controller_param,
        action: action_param,
        layout: controller.class.send(:_layout),
        **current_user_data_attributes,
        **current_item_data_attributes.to_h
      }
    }
  end

  def current_user_attributes
    %i[
      id name level level_string theme always_resize_images can_upload_free
      can_approve_posts disable_categorized_saved_searches
      disable_mobile_gestures disable_post_tooltips enable_auto_complete
      enable_post_navigation enable_safe_mode hide_deleted_posts
      show_deleted_children style_usernames
    ] + User::Roles.map { |role| :"is_#{role}?" }
  end

  def data_attributes_for(record, prefix, attributes)
    attributes.map do |attr|
      if attr.is_a?(Array)
        name = attr.map {|sym| sym.to_s.dasherize.delete("?")}.join('-')
        value = record
        attr.each do |sym|
          value = value.send(sym)
          if value.nil?
            break
          end
        end
      else
        name = attr.to_s.dasherize.delete("?")
        value = record.send(attr)
      end
      if value.nil?
        value = "null"
      end
      if prefix.blank?
        [:"#{name}", value]
      else
        [:"#{prefix}-#{name}", value]
      end
    end.to_h
  end

  def page_title(title = nil, suffix: "| #{Danbooru.config.app_name}")
    if title.present?
      content_for(:page_title) { "#{title} #{suffix}".strip }
    elsif content_for(:page_title).present?
      content_for(:page_title)
    elsif params[:action] == "index"
      "#{params[:controller].titleize} #{suffix}"
    elsif params[:action] == "show"
      "#{params[:controller].singularize.titleize} #{suffix}"
    elsif params[:action] == "new"
      "New #{params[:controller].singularize.titleize} #{suffix}"
    elsif params[:action] == "edit"
      "Edit #{params[:controller].singularize.titleize} #{suffix}"
    elsif params[:action] == "search"
      "Search #{params[:controller].titleize} #{suffix}"
    else
      "#{Danbooru.config.app_name}/#{params[:controller]}"
    end
  end

  def meta_description(description = nil)
    if description.present?
      content_for(:meta_description) { description }
    elsif content_for(:meta_description).present?
      content_for(:meta_description)
    end
  end

  def atom_feed_tag(title, url = {})
    content_for(:html_header, auto_discovery_link_tag(:atom, url, title: title))
  end

  protected

  def nav_link_match(controller, url)
    url =~ case controller
    when "sessions", "users", "admin/users"
      /^\/(session|users)/

    when "comments"
      /^\/comments/

    when "notes", "note_versions"
      /^\/notes/

    when "posts", "uploads", "post_versions", "explore/posts", "moderator/post/dashboards", "favorites"
      /^\/post/

    when "artists", "artist_versions"
      /^\/artist/

    when "tags", "tag_aliases", "tag_implications"
      /^\/tags/

    when "pools", "pool_versions"
      /^\/pools/

    when "moderator/dashboards"
      /^\/moderator/

    when "wiki_pages", "wiki_page_versions"
      /^\/wiki_pages/

    when "forum_topics", "forum_posts"
      /^\/forum_topics/

    else
      /^\/static/
    end
  end
end
