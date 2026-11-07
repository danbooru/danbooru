# frozen_string_literal: true

class ReadOnlyModeMiddleware
  SAFE_METHODS = %w[GET HEAD OPTIONS].freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless Danbooru.config.read_only_mode?

    request = ActionDispatch::Request.new(env)
    return read_only_response(request) unless request.request_method.in?(SAFE_METHODS)

    begin
      ActiveRecord::Base.while_preventing_writes { @app.call(env) }
    rescue ActiveRecord::ReadOnlyError
      read_only_response(request)
    end
  end

  private

  def read_only_response(request)
    message = "The site is in read-only mode. You can browse, but you can't make changes right now."
    headers = { "Cache-Control" => "no-store" }
    path = request.path

    if request.format.json? || path.end_with?(".json")
      headers["Content-Type"] = "application/json; charset=utf-8"
      body = { success: false, error: "ReadOnlyError", message: message }.to_json
    elsif request.format.xml? || path.end_with?(".xml")
      headers["Content-Type"] = "application/xml; charset=utf-8"
      body = { success: false, error: "ReadOnlyError", message: message }.to_xml
    else
      headers["Content-Type"] = "text/html; charset=utf-8"
      body = <<~HTML
        <!doctype html>
        <html lang="en">
          <head>
            <meta charset="utf-8">
            <title>Read-only mode</title>
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <style>body{margin:3em auto;max-width:40em;padding:0 1em;font-family:Verdana,Helvetica,sans-serif;line-height:1.5}h1{font-family:Tahoma}</style>
          </head>
          <body>
            <h1>Read-only mode</h1>
            <p>#{message}</p>
            <p><a href="/">Return to the home page</a></p>
          </body>
        </html>
      HTML
    end

    [503, headers, [body]]
  end
end
