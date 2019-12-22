class DanbooruLogger
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
    request_params = request.parameters.with_indifferent_access.except(:controller, :action)
    session_params = session.to_h.with_indifferent_access.slice(:session_id, :started_at)
    user_params = { id: user&.id, name: user&.name, level: user&.level_string, ip: request.remote_ip, safe_mode: CurrentUser.safe_mode? }

    add_attributes("request.params", request_params)
    add_attributes("session.params", session_params)
    add_attributes("user", user_params)
  end

  def self.add_attributes(prefix, hash)
    return unless defined?(::NewRelic)

    attributes = flatten_hash(hash).transform_keys { |key| "#{prefix}.#{key}" }
    attributes.delete_if { |key, value| key.end_with?(*Rails.application.config.filter_parameters.map(&:to_s)) }
    ::NewRelic::Agent.add_custom_attributes(attributes)
  end

  private_class_method

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
