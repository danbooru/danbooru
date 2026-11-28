# frozen_string_literal: true

module RuboCop
  module Cop
    module Danbooru
      # Use the helpers for source extractors instead of the standard library versions. See
      # CONTRIBUTING.md#source-extractors.
      #
      # * `String#parse_json` returns nil on invalid JSON instead of raising an error.
      # * `Danbooru::URL.escape` escapes URL components the same way everywhere.
      # * The extractor's `http` and `parsed_get` block local IPs, cache responses, and return nil on failure.
      #
      # @example
      #   # bad
      #   json = JSON.parse(Danbooru::Http.external.get(url).to_s)
      #   tag_url = "https://example.com/tags/#{CGI.escape(tag)}"
      #
      #   # good
      #   json = http.cache(1.minute).parsed_get(url)
      #   tag_url = "https://example.com/tags/#{Danbooru::URL.escape(tag)}"
      class ExtractorHelpers < Base
        JSON_MSG = "Use `String#parse_json` instead of `JSON.parse`. It returns nil on invalid JSON instead of raising an error. See CONTRIBUTING.md#source-extractors."
        ESCAPE_MSG = "Use `Danbooru::URL.escape` instead of `CGI.escape`. See CONTRIBUTING.md#source-extractors."
        HTTP_MSG = "Use the extractor's `http` or `parsed_get` instead of creating a new HTTP client. See CONTRIBUTING.md#source-extractors."

        def_node_matcher :json_parse?, "(send (const {nil? cbase} :JSON) :parse ...)"
        def_node_matcher :cgi_escape?, "(send (const {nil? cbase} :CGI) :escape ...)"
        def_node_matcher :new_http_client?, "(send (const (const {nil? cbase} :Danbooru) :Http) _ ...)"

        def on_send(node)
          if json_parse?(node)
            add_offense(node, message: JSON_MSG)
          elsif cgi_escape?(node)
            add_offense(node, message: ESCAPE_MSG)
          elsif new_http_client?(node)
            add_offense(node, message: HTTP_MSG)
          end
        end
      end
    end
  end
end
