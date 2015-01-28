module Sources::Strategies
  class Twitter < Base
    def self.url_match?(url)
      url =~ %r!https?://mobile\.twitter\.com/\w+/status/\d+!
    end

    def tags
      []
    end

    def site_name
      "Twitter"
    end

    def get
      agent.get(url) do |page|
        puts page.body
        @artist_name, @profile_url = get_profile_from_page(page)
        @image_url = get_image_url_from_page(page)
      end
    end

    def get_profile_from_page(page)
      links = page.search("a.profile-link")
      if links.any?
        profile_url = "https://twitter.com" + links[0]["href"]
        artist_name = links[0].search("span")[0].text
      else
        profile_url = nil
        artist_name = nil
      end

      return [artist_name, profile_url].compact
    end

    def get_image_url_from_page(page)
      divs = page.search("div.media")

      if divs.any?
        image_url = divs.search("img")[0]["src"] + ":large"
      else
        image_url = nil
      end

      return image_url
    end

    private

    def add_cookie(mech, name, value)
      cookie = Mechanize::Cookie.new(name, value)
      cookie.domain = ".twitter.com"
      cookie.path = "/"
      mech.cookie_jar.add(cookie)
    end

    def agent
      @agent ||= begin
        mech = Mechanize.new
        session = Cache.get("twitter-session")
        auth_token = Cache.get("twitter-auth-token")

        if session && auth_token
          add_cookie(mech, "_twitter_sess", session)
          add_cookie(mech, "auth_token", auth_token)

        elsif Danbooru.config.twitter_login
          mech.get("https://twitter.com/login") do |page|
            page.form_with(:action => "https://twitter.com/sessions") do |form|
              form["session[username_or_email]"] = Danbooru.config.twitter_login
              form["session[password]"] = Danbooru.config.twitter_password
            end.click_button
          end
          session = mech.cookie_jar.cookies.select{|c| c.name == "_twitter_sess"}.first
          Cache.put("twitter-session", session.value, 1.month) if session
          auth_token = mech.cookie_jar.cookies.select{|c| c.name == "auth_token"}.first
          Cache.put("twitter-auth-token", auth_token.value, 1.month) if auth_token
        end

        mech
      end
    end
  end
end
