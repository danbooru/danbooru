#if Danbooru.config.elastic_apm_server_url.present?
#  require "elastic_apm"
#
#  # https://www.elastic.co/guide/en/apm/agent/ruby/4.x/api.html#api-agent-start
#  # https://www.elastic.co/guide/en/apm/agent/ruby/4.x/configuration.html
#  ElasticAPM::Rails.start(
#    server_url: Danbooru.config.elastic_apm_server_url,
#    service_name: Danbooru.config.app_name,
#    service_version: Rails.application.config.x.git_hash,
#  )
#end
