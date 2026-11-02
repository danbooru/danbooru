# Rails parses GET query strings with ActionDispatch::ParamBuilder, which ignores Rack's POST query parser limits set in
# config/puma.rb (RACK_QUERY_PARSER_BYTESIZE_LIMIT, RACK_QUERY_PARSER_PARAMS_LIMIT and RACK_PARAM_DEPTH_LIMIT). Enforce
# them here.

ActionDispatch::QueryParser.singleton_class.prepend(Module.new do
  def each_pair(query_string, separator = nil)
    return super unless block_given?
    return super if separator.present? && separator != "&"

    bytesize_limit = Rack::Utils.default_query_parser.instance_variable_get(:@bytesize_limit)
    params_limit = Rack::Utils.default_query_parser.instance_variable_get(:@params_limit)

    if query_string.bytesize > bytesize_limit
      raise Rack::QueryParser::QueryLimitError, "total query size exceeds limit (#{bytesize_limit})"
    end

    params_count = query_string.empty? ? 0 : query_string.count("&") + 1
    if params_count > params_limit
      raise Rack::QueryParser::QueryLimitError, "total number of query parameters (#{params_count}) exceeds limit (#{params_limit})"
    end

    super
  end
end)

ActionDispatch::ParamBuilder.prepend(Module.new do
  delegate :param_depth_limit, to: "Rack::Utils"
end)
