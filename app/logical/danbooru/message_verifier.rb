module Danbooru
  class MessageVerifier
    attr_reader :purpose, :secret, :verifier

    def initialize(purpose)
      @purpose = purpose
      @secret = Rails.application.key_generator.generate_key(purpose.to_s)
      @verifier = ActiveSupport::MessageVerifier.new(secret, serializer: JSON, digest: "SHA256")
    end

    def generate(*args, **options)
      verifier.generate(*args, purpose: purpose, **options)
    end

    def verify(*args, **options)
      verifier.verify(*args, purpose: purpose, **options)
    end

    def verified(*args, **options)
      verifier.verified(*args, purpose: purpose, **options)
    end
  end
end
