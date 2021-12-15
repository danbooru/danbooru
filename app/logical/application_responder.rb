# frozen_string_literal: true

# Hooks into `respond_with` to add some custom behavior, including support for
# the `expires_in`, `expiry`, and `only` params.
#
# @see https://github.com/plataformatec/responders
# @see https://github.com/plataformatec/responders/blob/master/lib/action_controller/responder.rb
class ApplicationResponder < ActionController::Responder
  # this is called by respond_with for non-html, non-js responses.
  def to_format
    params = request.params

    if get?
      if params["expires_in"]
        expires_in = params["expires_in"]
        expires_in += "seconds" if expires_in =~ /\d+\z/
        controller.expires_in(DurationParser.parse(expires_in))
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
