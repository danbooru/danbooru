require 'dtext'

module ApplicationHelper
  def diff_list_html(new, old, latest)
    diff = SetDiff.new(new, old, latest)
    render "diff_list", diff: diff
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

  def link_to_wikis(*wiki_titles, last_word_connector: ", or", **options)
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
    user_class += " user-super-voter" if user.is_super_voter?
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

  def quick_search_form_for(attribute, url, name, autocomplete: nil, &block)
    tag.li do
      search_form_for(url, classes: "quick-search-form one-line-form") do |f|
        out  = f.input attribute, label: false, placeholder: "Search #{name}", input_html: { id: nil, "data-autocomplete": autocomplete }
        out += tag.input type: :hidden, name: :redirect, value: 1
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

  def table_for(*options, &block)
    table = TableBuilder.new(*options, &block)
    render "table_builder/table", table: table
  end

  def body_attributes(user = CurrentUser.user)
    attributes = %i[id name level level_string theme] + User::BOOLEAN_ATTRIBUTES.map(&:to_sym)
    attributes += User::Roles.map { |role| :"is_#{role}?" }

    controller_param = params[:controller].parameterize.dasherize
    action_param = params[:action].parameterize.dasherize

    {
      lang: "en",
      class: "c-#{controller_param} a-#{action_param}",
      data: {
        controller: controller_param,
        action: action_param,
        layout: controller.class.send(:_layout),
        **data_attributes_for(user, "user", attributes)
      }
    }
  end

  def data_attributes_for(record, prefix, attributes)
    attributes.map do |attr|
      name = attr.to_s.dasherize.delete("?")
      value = record.send(attr)

      [:"#{prefix}-#{name}", value]
    end.to_h
  end

  def page_title
    if content_for(:page_title).present?
      content_for(:page_title)
    elsif params[:action] == "index"
      "#{params[:controller].titleize} - #{Danbooru.config.app_name}"
    elsif params[:action] == "show"
      "#{params[:controller].singularize.titleize} - #{Danbooru.config.app_name}"
    elsif params[:action] == "new"
      "New #{params[:controller].singularize.titleize} - #{Danbooru.config.app_name}"
    elsif params[:action] == "edit"
      "Edit #{params[:controller].singularize.titleize} - #{Danbooru.config.app_name}"
    elsif params[:action] == "search"
      "Search #{params[:controller].titleize} - #{Danbooru.config.app_name}"
    else
      "#{Danbooru.config.app_name}/#{params[:controller]}"
    end
  end

  def show_moderation_notice?
    CurrentUser.can_approve_posts? && (cookies[:moderated].blank? || Time.at(cookies[:moderated].to_i) < 72.hours.ago)
  end

  protected

  def nav_link_match(controller, url)
    url =~ case controller
    when "sessions", "users", "maintenance/user/password_resets", "admin/users"
      /^\/(session|users)/

    when "comments"
      /^\/comments/

    when "notes", "note_versions"
      /^\/notes/

    when "posts", "uploads", "post_versions", "explore/posts", "moderator/post/dashboards", "favorites"
      /^\/post/

    when "artists", "artist_versions"
      /^\/artist/

    when "tags", "meta_searches"
      /^\/tags/

    when "pools", "pool_versions"
      /^\/pools/

    when "moderator/dashboards"
      /^\/moderator/

    when "tag_aliases", "tag_alias_requests"
      /^\/tag_aliases/

    when "tag_implications", "tag_implication_requests"
      /^\/tag_implications/

    when "wiki_pages", "wiki_page_versions"
      /^\/wiki_pages/

    when "forum_topics", "forum_posts"
      /^\/forum_topics/

    else
      /^\/static/
    end
  end
end
