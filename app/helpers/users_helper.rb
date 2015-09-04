module UsersHelper
  def email_sig(user)
    digest = OpenSSL::Digest.new("sha256")
    OpenSSL::HMAC.hexdigest(digest, Danbooru.config.email_key, user.id.to_s)
  end
end
