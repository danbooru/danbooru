# https://github.com/plataformatec/responders
# https://github.com/plataformatec/responders/blob/master/lib/action_controller/responder.rb
class ApplicationResponder < ActionController::Responder
  # this is called by respond_with for non-html, non-js responses.
  def to_format
    if get?
      expiry = request.params["expiry"]
      controller.expires_in expiry.to_i.days if expiry.present?
    end

    if format == :xml
      options[:root] ||= resource.table_name.dasherize if resource.respond_to?(:table_name)
    end

    super
  end
end
