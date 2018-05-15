module UploadsHelper
  def ccs_build_sig(url)
    return nil unless Danbooru.config.ccs_server.present?

    ref = ImageProxy.fake_referer_for(url)
    verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.ccs_key, serializer: JSON, digest: "SHA256")
    verifier.generate("#{url},#{ref}")
  end
end
