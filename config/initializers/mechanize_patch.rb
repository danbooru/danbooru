require 'mechanize'

if Rails.env.test?
  # something about the root certs on the travis ci image causes Mechanize
  # to intermittently fail. this is a monkey patch to reset the connection
  # after every request to avoid dealing wtiht he issue.
  #
  # from http://scottwb.com/blog/2013/11/09/defeating-the-infamous-mechanize-too-many-connection-resets-bug/
  class Mechanize::HTTP::Agent
    MAX_RESET_RETRIES = 10

    # We need to replace the core Mechanize HTTP method:
    #
    #   Mechanize::HTTP::Agent#fetch
    #
    # with a wrapper that handles the infamous "too many connection resets"
    # Mechanize bug that is described here:
    #
    #   https://github.com/sparklemotion/mechanize/issues/123
    #
    # The wrapper shuts down the persistent HTTP connection when it fails with
    # this error, and simply tries again. In practice, this only ever needs to
    # be retried once, but I am going to let it retry a few times
    # (MAX_RESET_RETRIES), just in case.
    #
    def fetch_with_retry(
      uri,
      method    = :get,
      headers   = {},
      params    = [],
      referer   = current_page,
      redirects = 0
    )
      action      = "#{method.to_s.upcase} #{uri}"
      retry_count = 0

      begin
        fetch_without_retry(uri, method, headers, params, referer, redirects)
      rescue Net::HTTP::Persistent::Error => e
        # Pass on any other type of error.
        raise unless e.message =~ /too many connection resets/

        # Pass on the error if we've tried too many times.
        if retry_count >= MAX_RESET_RETRIES
          print "R"
          # puts "**** WARN: Mechanize retried connection reset #{MAX_RESET_RETRIES} times and never succeeded: #{action}"
          raise
        end

        # Otherwise, shutdown the persistent HTTP connection and try again.
        print "R"
        # puts "**** WARN: Mechanize retrying connection reset error: #{action}"
        retry_count += 1
        self.http.shutdown
        retry
      end
    end

    # Alias so #fetch actually uses our new #fetch_with_retry to wrap the
    # old one aliased as #fetch_without_retry.
    alias fetch_without_retry fetch
    alias fetch fetch_with_retry
  end
end
