# https://github.com/plataformatec/responders
# https://github.com/plataformatec/responders/blob/master/lib/action_controller/responder.rb
class ApplicationResponder < ActionController::Responder
  # this is called by respond_with for non-html, non-js responses.
  def to_format
    params = request.params

    if get?
      if params["expires_in"]
        controller.expires_in(DurationParser.parse(params["expires_in"]))
      elsif request.params["expiry"]
        controller.expires_in(params["expiry"].to_i.days)
      end
    end

    if format == :xml
      options[:root] ||= resource.table_name.dasherize if resource.respond_to?(:table_name)
    end

    options[:only] ||= params["only"] if params["only"]

    super
  end
end
