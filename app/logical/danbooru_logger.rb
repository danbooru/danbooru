class DanbooruLogger
  HEADERS = %w[referer sec-fetch-dest sec-fetch-mode sec-fetch-site sec-fetch-user]

  def self.info(message, params = {})
    Rails.logger.info(message)

    if defined?(::NewRelic)
      params = flatten_hash(params).symbolize_keys
      ::NewRelic::Agent.record_custom_event(:info, message: message, **params)
    end
  end

  def self.log(exception, expected: false, **params)
    if expected
      Rails.logger.info("#{exception.class}: #{exception.message}")
    else
      backtrace = Rails.backtrace_cleaner.clean(exception.backtrace).join("\n")
      Rails.logger.error("#{exception.class}: #{exception.message}\n#{backtrace}")
    end

    if defined?(::NewRelic)
      ::NewRelic::Agent.notice_error(exception, expected: expected, custom_params: params)
    end
  end

  def self.add_session_attributes(request, session, user)
    add_attributes("request", { path: request.path })
    add_attributes("request.headers", header_params(request))
    add_attributes("request.params", request_params(request))
    add_attributes("session.params", session_params(session))
    add_attributes("user", user_params(request, user))
  end

  def self.header_params(request)
    headers = request.headers.to_h.select { |header, value| header.match?(/\AHTTP_/) }
    headers = headers.transform_keys { |header| header.delete_prefix("HTTP_").downcase }
    headers = headers.select { |header, value| header.in?(HEADERS) }
    headers
  end

  def self.request_params(request)
    request.parameters.with_indifferent_access.except(:controller, :action)
  end

  def self.session_params(session)
    session.to_h.with_indifferent_access.slice(:session_id, :started_at)
  end

  def self.user_params(request, user)
    {
      id: user&.id,
      name: user&.name,
      level: user&.level_string,
      ip: request.remote_ip,
      country: CurrentUser.country,
      safe_mode: CurrentUser.safe_mode?
    }
  end

  def self.add_attributes(prefix, hash)
    attributes = flatten_hash(hash).transform_keys { |key| "#{prefix}.#{key}" }
    attributes.delete_if { |key, value| key.end_with?(*Rails.application.config.filter_parameters.map(&:to_s)) }
    add_custom_attributes(attributes)
  end

  private_class_method

  def self.add_custom_attributes(attributes)
    return unless defined?(::NewRelic)
    ::NewRelic::Agent.add_custom_attributes(attributes)
  end

  # flatten_hash({ foo: { bar: { baz: 42 } } })
  # => { "foo.bar.baz" => 42 }
  def self.flatten_hash(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a?(Hash)
        flatten_hash(v).map do |h_k, h_v|
          h["#{k}.#{h_k}"] = h_v
        end
      else
        h[k.to_s] = v
      end
    end
  end
end
