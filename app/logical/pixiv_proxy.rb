class PixivProxy < ActiveRecord::Base
  def self.is_pixiv?(url)
    url =~ /pixiv\.net/
  end
  
  def self.get(url)
    if url =~ /\/(\d+)(_m|_p\d+)?\.(jpg|jpeg|png|gif)/i
      url = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{$1}"
      get_single(url)
    elsif url =~ /member_illust\.php/ && url =~ /illust_id=/
      get_single(url)
    else
      {}
    end
  end
  
  def self.get_profile_from_page(page)
    links = page.search("div.front-subContent a").find_all do |node|
      node["href"] =~ /member\.php/
    end
    
    if links.any?
      profile_url = links[0]["href"]
      children = links[0].children
      artist = children[0]["alt"]
      return [artist, profile_url]
    else
      return []
    end
  end
  
  def self.get_image_url_from_page(page)
    meta = page.search("meta[property=\"og:image\"]").first
    if meta
      meta.attr("content").sub(/_m\./, ".")
    else
      nil
    end
  end
  
  def self.get_jp_tags_from_page(page)
    links = page.search("div.pedia li a").find_all do |node|
      node["href"] =~ /tags\.php/
    end
    
    if links.any?
      links.map do |node|
        [node.inner_text, node.attr("href")]
      end
    else
      []
    end
  end
  
  def self.get_single(url)
    url = URI.parse(url).request_uri
    mech = create_mechanize
    hash = {}
    mech.get(url) do |page|
      artist, profile_url = get_profile_from_page(page)
      image_url = get_image_url_from_page(page)
      jp_tags = get_jp_tags_from_page(page)
      
      hash[:artist] = artist
      hash[:profile_url] = profile_url
      hash[:image_url] = image_url
      hash[:jp_tags] = jp_tags
    end
    hash
  end
  
  def self.create_mechanize
    mech = Mechanize.new
    
    mech.get("http://www.pixiv.net") do |page|
      page.form_with(:action => "/login.php") do |form|
        form['mode'] = "login"
        form['login_pixiv_id'] = "uroobnad"
        form['pass'] = "uroobnad556"
      end.click_button
    end
    
    mech
  end
end
