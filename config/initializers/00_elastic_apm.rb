ENV["ELASTIC_APM_ENABLED"] = "false" unless ENV["ELASTIC_APM_SERVER_URL"].present?

Rails.application.config.to_prepare do
  if ElasticAPM.running?
    ElasticAPM.agent.config.service_version ||= Rails.application.config.x.git_hash
    ElasticAPM.agent.config.service_node_name ||= ENV["NODE_NAME"]

    ElasticAPM.add_filter(:transaction_filter) do |event|
      name, _ = event.first

      if name == :transaction
        event.dig(:transaction, :context, :request, :url).except!(:protocol, :port)
        event.dig(:transaction, :context, :request, :headers).slice!(*%w[User-Agent Referer Save-Data X-Forwarded-For Accept-Language])
        event.dig(:transaction, :context, :response, :headers).slice!("Content-Type")
      else
        event
      end
    end
  end
end
