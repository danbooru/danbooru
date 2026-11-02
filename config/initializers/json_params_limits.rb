# Rails parses `Content-Type: application/json` request bodies without applying Rack's query parser limits. Enforce the
# same limits here (RACK_QUERY_PARSER_BYTESIZE_LIMIT, RACK_QUERY_PARSER_PARAMS_LIMIT, and RACK_PARAM_DEPTH_LIMIT, set in
# config/puma.rb).

# @param request_body [String] The raw request body
def parse_json(request_body)
  bytesize_limit = Rack::Utils.default_query_parser.instance_variable_get(:@bytesize_limit)
  param_limit = Rack::Utils.default_query_parser.instance_variable_get(:@params_limit)

  if request_body.bytesize > bytesize_limit
    raise Rack::QueryParser::QueryLimitError, "request size (#{request_body.bytesize}) exceeds limit (#{bytesize_limit})"
  end

  data = ActiveSupport::JSON.decode(request_body, max_nesting: Rack::Utils.param_depth_limit)
  count = data.is_a?(Hash) ? data.size : 1

  if count > param_limit
    raise Rack::QueryParser::QueryLimitError, "total number of parameters (#{count}) exceeds limit (#{param_limit})"
  end

  data.is_a?(Hash) ? data : { _json: data }
end

ActionDispatch::Request.parameter_parsers = ActionDispatch::Request.parameter_parsers.merge(json: method(:parse_json))
