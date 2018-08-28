require 'dtext'

module ApplicationHelper
  def wordbreakify(string)
    lines = string.scan(/.{1,10}/)
    wordbreaked_string = lines.map{|str| h(str)}.join("<wbr>")
    raw(wordbreaked_string)
  end

  def nav_link_to(text, url, **options)
    if nav_link_match(params[:controller], url)
      klass = "current"
    else
      klass = nil
    end

    li_link_to(text, url, id_prefix: "nav-", class: klass, **options)
  end

  def subnav_link_to(text, url, **options)
    li_link_to(text, url, id_prefix: "subnav-", **options)
  end

  def li_link_to(text, url, id_prefix: "", **options)
    klass = options.delete(:class)
    id = id_prefix + text.downcase.gsub(/[^a-z ]/, "").parameterize
    tag.li(link_to(text, url, options), id: id, class: klass)
  end

  def fast_link_to(text, link_params, options = {})
    if options
      attributes = options.map do |k, v|
        %{#{k}="#{h(v)}"}
      end.join(" ")
    else
      attributes = ""
    end

    if link_params.is_a?(Hash)
      action = link_params.delete(:action)
      controller = link_params.delete(:controller) || controller_name
      id = link_params.delete(:id)

      link_params = link_params.map {|k, v| "#{k}=#{u(v)}"}.join("&")

      if link_params.present?
        link_params = "?#{link_params}"
      end

      if id
        url = "/#{controller}/#{action}/#{id}#{link_params}"
      else
        url = "/#{controller}/#{action}#{link_params}"
      end
    else
      url = link_params
    end

    raw %{<a href="#{h(url)}" #{attributes}>#{text}</a>}
  end

  def format_text(text, **options)
    raw DTextRagel.parse(text, **options)
  rescue DTextRagel::Error => e
    raw ""
  end

  def strip_dtext(text)
    format_text(text, strip: true)
  end

  def error_messages_for(instance_name)
    instance = instance_variable_get("@#{instance_name}")

    if instance && instance.errors.any?
      %{<div class="error-messages ui-state-error ui-corner-all"><strong>Error</strong>: #{instance.__send__(:errors).full_messages.join(", ")}</div>}.html_safe
    else
      ""
    end
  end

  def time_tag(content, time)
    datetime = time.strftime("%Y-%m-%dT%H:%M%:z")

    content_tag(:time, content || datetime, :datetime => datetime, :title => time.to_formatted_s)
  end

  def humanized_duration(from, to)
    duration = distance_of_time_in_words(from, to)
    datetime = from.iso8601 + "/" + to.iso8601
    title = "#{from.strftime("%Y-%m-%d %H:%M")} to #{to.strftime("%Y-%m-%d %H:%M")}"

    raw content_tag(:time, duration, datetime: datetime, title: title)
  end

  def time_ago_in_words_tagged(time, compact: false)
    if time.past?
      text = time_ago_in_words(time) + " ago"
      text = text.gsub(/almost|about|over/, "") if compact
      raw time_tag(text, time)
    else
      raw time_tag("in " + distance_of_time_in_words(Time.now, time), time)
    end
  end

  def compact_time(time)
    time_tag(time.strftime("%Y-%m-%d %H:%M"), time)
  end

  def external_link_to(url, options = {})
    if options[:truncate]
      text = truncate(url, length: options[:truncate])
    else
      text = url
    end

    if url =~ %r!\Ahttps?://!i
      link_to text, url, {rel: :nofollow}
    else
      url
    end
  end

  def link_to_ip(ip)
    link_to ip, moderator_ip_addrs_path(:search => {:ip_addr => ip})
  end

  def link_to_search(search)
    link_to search, posts_path(tags: search)
  end

  def link_to_wiki(*wiki_titles, **options)
    links = wiki_titles.map do |title|
      link_to title.tr("_", " "), wiki_pages_path(title: title)
    end

    to_sentence(links, **options)
  end

  def link_to_user(user, options = {})
    user_class = user.level_class
    user_class = user_class + " user-post-approver" if user.can_approve_posts?
    user_class = user_class + " user-post-uploader" if user.can_upload_free?
    user_class = user_class + " user-super-voter" if user.is_super_voter?
    user_class = user_class + " user-banned" if user.is_banned?
    user_class = user_class + " with-style" if CurrentUser.user.style_usernames?
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

  def dtext_preview_button(object, name, options = {})
    options[:input_id] ||= "#{object}_#{name}"
    options[:preview_id] ||= "dtext-preview"
    submit_tag("Preview", "data-input-id" => options[:input_id], "data-preview-id" => options[:preview_id])
  end

  def search_field(method, label: method.titleize, hint: nil, value: nil, **attributes)
    content_tag(:div, class: "input") do
      label_html = label_tag("search_#{method}", label)
      input_html = text_field_tag(method, value, id: "search_#{method}", name: "search[#{method}]", **attributes)
      hint_html = hint.present? ? content_tag(:p, hint, class: "hint") : ""

      label_html + input_html + hint_html
    end
  end

  def body_attributes(user = CurrentUser.user)
    attributes = [:id, :name, :level, :level_string, :can_approve_posts?, :can_upload_free?]
    attributes += User::Roles.map { |role| :"is_#{role}?" }

    controller_param = params[:controller].parameterize.dasherize
    action_param = params[:action].parameterize.dasherize

    {
      lang: "en",
      class: "c-#{controller_param} a-#{action_param}",
      data: {
        controller: controller_param,
        action: action_param,
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
  
protected
  def nav_link_match(controller, url)
    url =~ case controller
    when "sessions", "users", "maintenance/user/login_reminders", "maintenance/user/password_resets", "admin/users"
      /^\/(session|users)/

    when "forum_posts"
      /^\/forum_topics/

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

    when "tag_aliases", "tag_alias_corrections", "tag_alias_requests"
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
