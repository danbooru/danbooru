module UsersHelper
  def email_sig(user)
    verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.email_key, serializer: JSON, digest: "SHA256")
    verifier.generate(user.id.to_s)
  end
end
