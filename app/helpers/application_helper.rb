# frozen_string_literal: true

module ApplicationHelper
  USER_DATA_ATTRIBUTES = %i[
    id name level level_string theme comment_threshold default_image_size time_zone per_page
  ] + User::ACTIVE_BOOLEAN_ATTRIBUTES + User::Roles.map { |role| :"is_#{role}?" }

  COOKIE_DATA_ATTRIBUTES = %i[
    news-ticker hide_upgrade_account_notice hide_verify_account_notice
    hide_dmail_notice dab show-relationship-previews post_preview_size
    post_preview_show_votes
  ]

  def listing_type(*fields, member_check: true, types: [:revert, :standard])
    (fields.reduce(false) { |acc, field| acc || params.dig(:search, field).present? } && (!member_check || CurrentUser.is_member?) ? types[0] : types[1])
  end

  def diff_list_html(this_list, other_list, ul_class: ["diff-list"], li_class: [], show_unchanged: true)
    diff = SetDiff.new(this_list, other_list)
    render "diff_list", diff: diff, ul_class: ul_class, li_class: li_class, show_unchanged: show_unchanged
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
    %w[previous current].each do |type|
      if type == params[:type]
        html << %{<span>#{type}</span>}
      else
        html << tag.li(link_to(type, params.except(:controller, :action).merge(type: type).permit!))
      end
    end
    html.join(" | ").html_safe
  end

  def current_page_path(**params)
    url_for(request.query_parameters.merge(params))
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

  def format_text(text, references: DText.preprocess([text]), **options)
    DText.new(text, **options).format_text(references:)
  end

  def strip_dtext(text)
    DText.new(text).strip_dtext
  end

  def time_tag(content, time, **options)
    datetime = time.strftime("%Y-%m-%dT%H:%M%:z")

    tag.time content || datetime, datetime: datetime, title: time.to_formatted_s, **options
  end

  def duration_to_hhmmss(seconds)
    seconds = seconds.round
    hh = seconds.div(1.hour)
    mm = (seconds.seconds - hh.hours.seconds).div(1.minute)
    ss = "%.2d" % (seconds % 1.minute)

    if seconds >= 1.hour
      "#{hh}:#{mm}:#{ss}"
    elsif seconds >= 1.second
      "#{mm}:#{ss}"
    else
      "0:01"
    end
  end

  def duration_to_hhmmssms(seconds)
    hh = seconds.div(1.hour).to_s
    mm = seconds.div(1.minute).to_s
    ss = "%.2d" % (seconds % 1.minute)
    ms = ("%.3f" % (seconds % 1.second)).delete_prefix("0.")

    if seconds >= 1.hour
      "#{hh}:#{mm}:#{ss}.#{ms}"
    else
      "#{mm}:#{ss}.#{ms}"
    end
  end

  def humanized_number(number, million: "M", thousand: "k")
    if number >= 1_000_000
      format("%.1f#{million}", number / 1_000_000.0)
    elsif number >= 10_000
      "#{number / 1_000}#{thousand}"
    elsif number >= 1_000
      format("%.1f#{thousand}", number / 1_000.0)
    else
      number.to_s
    end
  end

  def humanized_time(time)
    if time.nil?
      tag.em(tag.time("unknown"))
    elsif time.past?
      if time > 1.day.ago
        human_time = time_ago_in_words(time).gsub(/about|over|less than|almost/, "")
        time_tag("#{human_time} ago", time)
      elsif time > Time.zone.today.beginning_of_year
        time_tag(time.strftime("%b %e"), time)
      else
        time_tag(time.strftime("%b %e, %Y"), time)
      end
    elsif time.future?
      if time < 1.day.from_now
        time_tag("in #{time_ago_in_words(time)}", time)
      else
        time_tag(time.strftime("%b %e, %Y"), time)
      end
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
    elsif time.future?
      if compact
        text = distance_of_time_in_words(Time.now, time)
        text = text.gsub(/almost|about|over/, "").gsub(/less than a/, "<1").strip
        time_tag(text, time)
      else
        time_tag("in " + distance_of_time_in_words(Time.now, time), time)
      end
    end
  end

  def compact_time(time)
    time_tag(time.strftime("%Y-%m-%d %H:%M"), time)
  end

  def external_link_to(url, text = url, truncate: nil, strip: false, **link_options, &block)
    text = capture { yield } if block_given?
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
    link_to ip_addr.to_s, user_events_path(search: { ip_addr: ip }), **options
  end

  def link_to_search(tag, **options)
    link_to tag.pretty_name, posts_path(tags: tag.name), class: tag_class(tag), **options
  end

  def link_to_wiki(text, title = text, classes: nil, **options)
    title = "~#{title}" if title =~ /\A\d+\z/
    link_to text, wiki_page_path(title), class: "wiki-link #{classes}", **options
  end

  def link_to_wikis(*wiki_titles, **options)
    links = wiki_titles.map do |title|
      link_to_wiki title.tr("_", " "), title
    end

    to_sentence(links, **options)
  end

  def link_to_media_asset(media_asset, url: media_asset, classes: nil, **options)
    duration_text = media_asset.duration.present? ? " (#{duration_to_hhmmss(media_asset.duration)})" : ""
    size_text = "#{media_asset.image_width}x#{media_asset.image_height}"
    file_text = "#{number_to_human_size(media_asset.file_size)} .#{media_asset.file_ext}"

    link_to("#{file_text}, #{size_text}#{duration_text}", url, class: classes, **options)
  end

  def link_to_user(user, text = nil, url: user, classes: nil, **options)
    return "anonymous" if user.blank?

    user_class = "user user-#{user.level_string.downcase} #{classes}".strip
    user_class += " user-banned" if user.is_banned?

    text = user.pretty_name if text.blank?
    data = { "user-id": user.id, "user-name": user.name, "user-level": user.level }
    link_to(text, url, class: user_class, data: data)
  end

  def embed_wiki(title, classes: nil, **options)
    wiki = WikiPage.find_by(title: title)
    text = wiki&.dtext_body&.format_text
    tag.div(text, class: "prose #{classes}".strip, **options)
  end

  # Generates a captcha widget inside a form.
  def captcha_tag(...)
    CaptchaService.new.captcha_tag(...)
  end

  def dtext_preview_button(preview_field, media_embeds: false, class: nil)
    klass = binding.local_variable_get(:class)
    tag.input value: "Preview", type: "button", class: "dtext-preview-button #{klass}", "data-preview-field": preview_field, "data-media-embeds": media_embeds
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

  def search_form_for(url, attribute: :search, classes: "inline-form", method: :get, &block)
    defaults = { required: false }
    html_options = { autocomplete: "off", novalidate: true, class: "search-form #{classes}" }

    simple_form_for(attribute, method: method, url: url, defaults: defaults, html: html_options) do |f|
      out = "".html_safe
      out += tag.input(type: :hidden, name: :limit, value: params[:limit]) if params[:limit].present?
      out += capture { yield f } if block_given?
      out
    end
  end

  def edit_form_for(model, validate: false, error_notice: true, warning_notice: true, **options, &block)
    options[:html] = { autocomplete: "off", novalidate: !validate, **options[:html].to_h }
    options[:authenticity_token] = true if options[:remote] == true

    simple_form_for(model, **options) do |form|
      if error_notice && model.try(:errors).try(:any?)
        concat tag.div(format_text(model.errors.full_messages.join("; ")), class: "notice notice-error notice-small prose")
      end

      if warning_notice && model.try(:warnings).try(:any?)
        concat tag.div(format_text(model.warnings.full_messages.join("; ")), class: "notice notice-info notice-small prose")
      end

      block.call(form)
    end
  end

  def table_for(...)
    table = TableBuilder.new(...)
    render "table_builder/table", table: table
  end

  def body_attributes(current_user, params, current_item, exception)
    if exception
      controller_param = "static"
      action_param = "error"
      layout = nil
      extra_attributes = {}
    else
      controller_param = params[:controller].parameterize.dasherize
      action_param = params[:action].parameterize.dasherize
      layout = controller.class.send(:_layout)
      extra_attributes = current_item_data_attributes(current_item)
    end

    {
      lang: "en",
      class: "c-#{controller_param} a-#{action_param} flex flex-col",
      spellcheck: "false",
      data: {
        controller: controller_param,
        action: action_param,
        layout: layout,
        "current-user-ip-addr": request.remote_ip,
        "current-user-save-data": CurrentUser.save_data,
        **data_attributes_for(current_user, "current-user", USER_DATA_ATTRIBUTES),
        **data_attributes_for(cookies, "cookie", COOKIE_DATA_ATTRIBUTES),
        **extra_attributes,
      }
    }
  end

  def current_item_data_attributes(current_item)
    if current_item.present? && current_item.respond_to?(:html_data_attributes) && current_item.respond_to?(:model_name)
      model_name = current_item.model_name.singular.dasherize
      model_attributes = current_item.html_data_attributes
      data_attributes_for(current_item, model_name, model_attributes)
    else
      {}
    end
  end

  def data_attributes_for(record, prefix = "data", attributes = record.html_data_attributes)
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
      elsif record.respond_to?(attr)
        name = attr.to_s.dasherize.delete("?")
        value = record.send(attr)
      else
        name = attr.to_s.dasherize.delete("?")
        value = record[attr]
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

  # Set the URL used in the <link rel="canonical" href="..."> tag for the
  # current page. If no URL is given, return the current canonical URL.
  def seo_canonical_url(url = nil, root_url: Danbooru.config.canonical_url)
    if url.present? && url.starts_with?("/")
      content_for(:seo_canonical_url) { root_url.chomp("/") + url }
    elsif url.present?
      content_for(:seo_canonical_url) { url }
    elsif content_for(:seo_canonical_url).present?
      content_for(:seo_canonical_url)
    else
      request_params = request.params.sort.to_h.with_indifferent_access
      request_params.delete(:page) if request_params[:page].to_i == 1
      request_params.delete(:limit)
      root_url.chomp("/") + url_for(**request_params, only_path: true)
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
