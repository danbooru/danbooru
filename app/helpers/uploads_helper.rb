module UploadsHelper
  def ccs_build_sig(url)
    return nil unless Danbooru.config.ccs_server.present?

    ref = ImageProxy.fake_referer_for(url)
    digest = OpenSSL::Digest.new("sha256")
    OpenSSL::HMAC.hexdigest(digest, Danbooru.config.ccs_key, "#{url},#{ref}")
  end
end
