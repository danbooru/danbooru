require "big_query"

module GoogleBigQuery
  class Base
    def self.enabled?
      File.exists?(Danbooru.config.google_api_json_key_path)
    end

    def initialize
      raise NotImplementedError.new("Google Big Query is not configured.") unless GoogleBigQuery::Base.enabled?
    end

    def query(q)
      client.query(q)
    end

    def escape(s)
      Regexp.escape(s).gsub(/\\/, '\0\0').gsub(/['"]/, '\\\\\0')
    end

    def client
      @_client ||= BigQuery::Client.new(
        "json_key" => client_options[:google_key_path],
        "project_id" => google_config["project_id"],
        "dataset" => client_options[:google_data_set]
      )
    end

    def client_options
      @_client_options ||= {
        google_key_path: Danbooru.config.google_api_json_key_path,
        google_data_set: "danbooru_#{Rails.env}"
      }
    end

    def google_config
      @_google_config ||= JSON.parse(File.read(client_options[:google_key_path]))
    end

    def data_set
      client_options[:google_data_set]
    end
  end
end
