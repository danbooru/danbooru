# https://github.com/plataformatec/responders
# https://github.com/plataformatec/responders/blob/master/lib/action_controller/responder.rb
class ApplicationResponder < ActionController::Responder
  # this is called by respond_with for non-html, non-js responses.
  def to_format
    if format == :xml
      options[:root] ||= resource.table_name.dasherize if resource.respond_to?(:table_name)
    end

    super
  end
end
