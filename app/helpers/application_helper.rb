module ApplicationHelper
  def nav_link_to(text, url, html_options = nil)
    if url.include?(params[:controller]) || (%w(tag_alias tag_implication).include?(params[:controller]) && url =~ /\/tag/)
      klass = "current-page"
    else
      klass = nil
    end
    
    (%{<li class="#{klass}">} + link_to(text, url, html_options) + "</li>").html_safe
  end

  def format_text(text, options = {})
    DText.parse(text)
  end

  def id_to_color(id)
    r = id % 255
    g = (id >> 8) % 255
    b = (id >> 16) % 255
    "rgb(#{r}, #{g}, #{b})"
  end

  def tag_header(tags)
    unless tags.blank?
      '/' + Tag.scan_query(tags).map {|t| link_to(h(t.tr("_", " ")), posts_path(:tags => t))}.join("+")
    end
  end
  
  def compact_time(time)
    if time > Time.now.beginning_of_day
      time.strftime("%H:%M")
    elsif time > Time.now.beginning_of_year
      time.strftime("%b %e")
    else
      time.strftime("%b %e, %Y")
    end
  end
  
  def print_preview(post, options = {})
    unless Danbooru.config.can_see_post?(post, @current_user)
      return ""
    end

    options = {:blacklist => true}.merge(options)

    blacklist = options[:blacklist] ? "blacklisted" : ""
    width, height = post.preview_dimensions
    image_id = options[:image_id]
    image_id = %{id="#{h(image_id)}"} if image_id
    title = "#{h(post.cached_tags)} rating:#{post.rating} score:#{post.score} uploader:#{h(post.uploader_name)}"

    content_for(:blacklist) {"Post.register(#{post.to_json});\n"} if options[:blacklist]
    
    %{
      <span class="thumb #{blacklist}" id="p#{post.id}">
        <a href="/posts/#{post.id}">
          <img #{image_id} class="preview #{'flagged' if post.is_flagged?} #{'pending' if post.is_pending?}" src="#{post.preview_url}" title="#{title}" alt="#{title}" width="#{width}" height="#{height}">
        </a>
      </span>
    }
  end
end
