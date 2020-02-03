module Danbooru
  class MessageVerifier
    attr_reader :purpose, :secret, :verifier

    def initialize(purpose)
      @purpose = purpose
      @secret = Rails.application.key_generator.generate_key(purpose.to_s)
      @verifier = ActiveSupport::MessageVerifier.new(secret, serializer: JSON, digest: "SHA256")
    end

    def generate(*options)
      verifier.generate(*options, purpose: purpose)
    end

    def verified(*options)
      verifier.verified(*options, purpose: purpose)
    end
  end
end
