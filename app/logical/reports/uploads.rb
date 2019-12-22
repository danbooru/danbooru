module Reports
  class Uploads
    attr_reader :min_date, :max_date, :queries

    def initialize(min_date, max_date, queries)
      if min_date.present?
        @min_date = min_date
      else
        @min_date = 30.days.ago.to_date
      end

      if max_date.present?
        @max_date = max_date
      else
        @max_date = Date.today
      end

      @queries = queries.to_s.split(/,\s*/).join(",")
    end

    def generate_sig
      verifier = ActiveSupport::MessageVerifier.new(Danbooru.config.reportbooru_key, serializer: JSON, digest: "SHA256")
      verifier.generate("#{min_date},#{max_date},#{queries}")
    end
  end
end
