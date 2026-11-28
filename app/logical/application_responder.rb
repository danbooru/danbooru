# frozen_string_literal: true

# Hooks into `respond_with` to add some custom behavior, including support for
# the `only` param and XML root element naming.
#
# @see https://github.com/plataformatec/responders
# @see https://github.com/plataformatec/responders/blob/master/lib/action_controller/responder.rb
class ApplicationResponder < ActionController::Responder
  # this is called by respond_with for non-html, non-js responses.
  def to_format
    params = request.params

    if format == :xml
      options[:root] ||= resource.table_name.dasherize if resource.respond_to?(:table_name)
    end

    options[:only] ||= params["only"] if params["only"]

    super
  end
end
