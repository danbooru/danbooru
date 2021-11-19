module ApplicationHelper
  def listing_type(*fields, member_check: true, types: [:revert, :standard])
    (fields.reduce(false) { |acc, field| acc || params.dig(:search, field).present? } && (!member_check || CurrentUser.is_member?) ? types[0] : types[1])
  end

  def diff_list_html(this_list, other_list, ul_class: ["diff-list"], li_class: [])
    diff = SetDiff.new(this_list, other_list)
    render "diff_list", diff: diff, ul_class: ul_class, li_class: li_class
  end

  def diff_name_html(this_name, other_name)
    DiffBuilder.new(this_name, other_name, /./).build
  end

  def diff_body_html(record, other, field)
    if record.blank? || other.blank?
      diff_record = other.presence || record
      return h(diff_record[field]).gsub(/\r?\n/, '<span class="paragraph-mark">¶</span><br>').html_safe
    end

    pattern = /(?:<.+?>)|(?:\w+)|(?:[ \t]+)|(?:\r?\n)|(?:.+?)/
    DiffBuilder.new(record[field], other[field], pattern).build
  end

  def status_diff_html(record, type)
    other = record.send(type)

    if other.blank?
      return type == "previous" ? "New" : ""
    end

    changed_fields = record.class.status_fields.select do |field, _status|
      (record.has_attribute?(field) && record[field] != other[field]) ||
        (!record.has_attribute?(field) && record.send(field, type))
    end

    statuses = changed_fields.map { |field, status| status }
    altered = record.updater_id != other.updater_id

    tag.div(class: "version-statuses", "data-altered": altered) do
      safe_join(statuses, tag.br)
    end
  end

  def wordbreakify(string)
    lines = string.scan(/.{1,10}/)
    wordbreaked_string = lines.map {|str| h(str)}.join("<wbr>")
    raw(wordbreaked_string)
  end

  def version_type_links(params)
    html = []
    %w[previous subsequent current].each do |type|
      if type == params[:type]
        html << %{<span>#{type}</span>}
      else
        html << tag.li(link_to(type, params.except(:controller, :action).merge(type: type).permit!))
      end
    end
    html.join(" | ").html_safe
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

  def time_tag(content, time, **options)
    datetime = time.strftime("%Y-%m-%dT%H:%M%:z")

    tag.time content || datetime, datetime: datetime, title: time.to_formatted_s, **options
  end

  def humanized_duration(duration)
    if duration >= 100.years
      "forever"
    else
      duration.inspect
    end
  end

  def duration_to_hhmmss(seconds)
    seconds = seconds.round
    hh = seconds.div(1.hour).to_s
    mm = seconds.div(1.minute).to_s
    ss = "%.2d" % (seconds % 1.minute)

    if seconds >= 1.hour
      "#{hh}:#{mm}:#{ss}"
    elsif seconds >= 1.second
      "#{mm}:#{ss}"
    else
      "0:01"
    end
  end

  def humanized_number(number)
    if number >= 1_000_000
      format("%.1fM", number / 1_000_000.0)
    elsif number >= 10_000
      "#{number / 1_000}k"
    elsif number >= 1_000
      format("%.1fk", number / 1_000.0)
    else
      number.to_s
    end
  end

  def time_ago_in_words_tagged(time, compact: false)
    if time.nil?
      tag.em(tag.time("unknown"))
    elsif time.past?
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
    text = text.gsub(%r{\Ahttps?://}i, "") if strip == :scheme
    text = text.gsub(%r{\Ahttps?://(?:www\.)?}i, "") if strip == :subdomain
    text = text.truncate(truncate) if truncate

    if url =~ %r{\Ahttps?://}i
      link_to text, url, rel: "external noreferrer nofollow", **link_options
    else
      url
    end
  end

  def link_to_ip(ip, shorten: false, **options)
    ip_addr = IPAddr.new(ip.to_s)
    ip_addr.prefix = 64 if ip_addr.ipv6? && shorten
    link_to ip_addr.to_s, ip_addresses_path(search: { ip_addr: ip, group_by: "user" }), **options
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

  def link_to_user(user, text = nil)
    return "anonymous" if user.blank?

    user_class = "user user-#{user.level_string.downcase}"
    user_class += " user-post-approver" if user.can_approve_posts?
    user_class += " user-post-uploader" if user.can_upload_free?
    user_class += " user-banned" if user.is_banned?

    text = user.pretty_name if text.blank?
    data = { "user-id": user.id, "user-name": user.name, "user-level": user.level }
    link_to(text, user, class: user_class, data: data)
  end

  def embed_wiki(title, **options)
    wiki = WikiPage.find_by(title: title)
    text = format_text(wiki&.body)
    tag.div(text, class: "prose", **options)
  end

  def dtext_preview_button(preview_field)
    tag.input value: "Preview", type: "button", class: "dtext-preview-button", "data-preview-field": preview_field
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

    simple_form_for(model, **options) do |form|
      if model.try(:errors).try(:any?)
        concat tag.div(model.errors.full_messages.join("; "), class: "notice notice-error notice-small")
      end

      block.call(form)
    end
  end

  def table_for(...)
    table = TableBuilder.new(...)
    render "table_builder/table", table: table
  end

  def body_attributes(user, params, current_item = nil)
    current_user_data_attributes = data_attributes_for(user, "current-user", current_user_attributes)

    if !current_item.nil? && current_item.respond_to?(:html_data_attributes) && current_item.respond_to?(:model_name)
      model_name = current_item.model_name.singular.dasherize
      model_attributes = current_item.html_data_attributes
      current_item_data_attributes = data_attributes_for(current_item, model_name, model_attributes)
    end

    controller_param = params[:controller].parameterize.dasherize
    action_param = params[:action].parameterize.dasherize

    {
      lang: "en",
      class: "c-#{controller_param} a-#{action_param}",
      spellcheck: "false",
      data: {
        controller: controller_param,
        action: action_param,
        layout: controller.class.send(:_layout),
        "current-user-ip-addr": request.remote_ip,
        **current_user_data_attributes,
        **current_item_data_attributes.to_h,
      }
    }
  end

  def current_user_attributes
    %i[
      id name level level_string theme always_resize_images can_upload_free
      can_approve_posts disable_categorized_saved_searches
      disable_mobile_gestures disable_post_tooltips enable_safe_mode
      hide_deleted_posts show_deleted_children style_usernames
      default_image_size
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

  def canonical_url(url = nil)
    if url.present?
      content_for(:canonical_url) { url }
    elsif content_for(:canonical_url).present?
      content_for(:canonical_url)
    else
      request_params = request.params.sort.to_h.with_indifferent_access
      request_params.delete(:page) if request_params[:page].to_i == 1
      request_params.delete(:limit)
      url_for(**request_params, host: Danbooru.config.hostname, only_path: false)
    end
  end

  def noindex
    content_for(:html_header, tag.meta(name: "robots", content: "noindex"))
  end

  def atom_feed_tag(title, url = {})
    content_for(:html_header, auto_discovery_link_tag(:atom, url, title: title))
  end

  protected

  def nav_link_match(controller, url)
    url =~ case controller
    when "sessions", "users", "admin/users"
      %r{^/(session|users)}

    when "comments"
      %r{^/comments}

    when "notes", "note_versions"
      %r{^/notes}

    when "posts", "uploads", "post_versions", "explore/posts", "moderator/post/dashboards", "favorites"
      %r{^/post}

    when "artists", "artist_versions"
      %r{^/artist}

    when "tags", "tag_aliases", "tag_implications"
      %r{^/tags}

    when "pools", "pool_versions"
      %r{^/pools}

    when "moderator/dashboards"
      %r{^/moderator}

    when "wiki_pages", "wiki_page_versions"
      %r{^/wiki_pages}

    when "forum_topics", "forum_posts"
      %r{^/forum_topics}

    else
      %r{^/static}
    end
  end
end
