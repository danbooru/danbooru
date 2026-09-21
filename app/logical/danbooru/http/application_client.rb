# frozen_string_literal: true

# An extension to HTTP::Client that lets us write Rack-style middlewares that
# hook into the request/response cycle and override how requests are made. This
# works by extending http.rb's concept of features (HTTP::Feature) to give them
# a `perform` method that takes a http request and returns a http response.
# This can be used to intercept and modify requests and return arbitrary responses.

module Danbooru
  class Http
    class ApplicationClient < HTTP::Client
      # Override `perform` to call the `perform` method on features first.
      # If the request raises an exception, it's turned into a fake response, so features never have to handle them directly.
      # @see Danbooru::Http::ERROR_STATUSES
      def perform(request, options)
        features = options.features.values.reverse.select do |feature|
          feature.respond_to?(:perform)
        end

        perform = proc do |req|
          super(req, options)
        rescue *Danbooru::Http::ERROR_STATUSES.keys => e
          Danbooru::Http.error_response(e, req.verb, req.uri)
        end
        callback_chain = features.reduce(perform) do |callback_chain, feature|
          proc { |req| feature.perform(req, &callback_chain) }
        end

        callback_chain.call(request)
      end

      # Override `branch` to return an ApplicationClient instead of a
      # HTTP::Client so that chaining works.
      def branch(...)
        ApplicationClient.new(...)
      end
    end
  end
end
