module Danbooru
  class MessageVerifier
    attr_reader :purpose, :secret, :verifier

    def initialize(purpose)
      @purpose = purpose
      @secret = Rails.application.key_generator.generate_key(purpose.to_s)
      @verifier = ActiveSupport::MessageVerifier.new(secret, serializer: JSON, digest: "SHA256")
    end

    def generate(value, **options)
      verifier.generate(value, purpose: purpose, **options)
    end

    def verify(value)
      verifier.verify(value, purpose: purpose)
    end

    def verified(value)
      verifier.verified(value, purpose: purpose)
    end
  end
end
