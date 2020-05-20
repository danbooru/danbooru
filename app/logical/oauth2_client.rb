class Oauth2Client
  attr_reader :site, :user, :client_id, :client_secret, :scope, :redirect_uri, :token_url, :base_authorization_url

  def self.from_state!(state, current_user)
    state = state_verifier.verify(state)
    user = User.find(state["user_id"])
    raise User::PrivilegeError unless user == current_user

    Oauth2Client.new(state["site"], scope: state["scope"], redirect_uri: state["redirect_uri"])
  end

  def initialize(site, scope: nil, redirect_uri: nil, client_id: nil, client_secret: nil)
    @site = site
    @redirect_uri = redirect_uri

    case @site
    when "Discord"
      @client_id = client_id || Danbooru.config.discord_client_id
      @client_secret = client_secret || Danbooru.config.discord_client_secret
      @scope = scope || "identify email"
      @token_url = "https://discord.com/api/oauth2/token"
      @base_authorization_url = "https://discord.com/api/oauth2/authorize"
    when "DeviantArt"
      @client_id = client_id || Danbooru.config.deviantart_client_id
      @client_secret = client_secret || Danbooru.config.deviantart_client_secret
      @scope = scope || "user"
      @token_url = "https://www.deviantart.com/oauth2/token"
      @base_authorization_url = "https://www.deviantart.com/oauth2/authorize"
    else
      @client_id = client_id
      @client_secret = client_secret
      @scope = scope || "identify"
    end
  end

  def authorization_url(user:)
    params = {
      response_type: "code",
      redirect_uri: redirect_uri,
      scope: scope,
      state: state(user),
      client_id: client_id,
    }

    "#{base_authorization_url}?#{params.to_query}"
  end

  def access_token(authorization_code)
    form_params = {
      grant_type: "authorization_code",
      code: authorization_code,
      scope: scope,
      redirect_uri: redirect_uri,
      client_id: client_id,
      client_secret: client_secret,
    }

    response = http.post(token_url, form: form_params)
    response.parse
  end

  def state(user)
    Oauth2Client.state_verifier.generate({ site: site, user_id: user.id, scope: scope, redirect_uri: redirect_uri }, expires_in: 5.minutes)
  end

  def self.state_verifier
    @state_verifier ||= Danbooru::MessageVerifier.new(:oauth_state)
  end

  def http
    @http ||= Danbooru::Http.new
  end
end
