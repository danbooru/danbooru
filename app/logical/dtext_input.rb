# frozen_string_literal: true

# A custom SimpleForm input for DText fields.
#
# Usage:
#
#   <%= f.input :body, as: :dtext %>
#
# https://github.com/heartcombo/simple_form/wiki/Custom-inputs-examples
# https://github.com/heartcombo/simple_form/blob/master/lib/simple_form/inputs/string_input.rb
# https://github.com/heartcombo/simple_form/blob/master/lib/simple_form/inputs/text_input.rb

class DtextInput < SimpleForm::Inputs::Base
  enable :placeholder

  def initialize(...)
    super
    inline = object.send("dtext_#{attribute_name}").inline
    options[:label] = false unless options[:label].present? || inline
    options[:wrapper_html] ||= {}
    options[:wrapper_html][:class] = "@container #{options[:wrapper_html][:class]}"

    if inline && maximum_length.present?
      options[:wrapper_html][:class] += " dtext-input-counter-wrapper"
      options[:wrapper_html]["x-data"] = "{ length: #{object.send(attribute_name).to_s.length} }"
    end
  end

  def input(wrapper_options)
    t = template
    input_options = merge_wrapper_options(input_html_options, wrapper_options)
    input_options[:maxlength] ||= maximum_length

    t.render(DtextEditorComponent.new(input_name: attribute_name, form: @builder, editor_html: options[:editor_html], input_html: input_options))
  end

  private

  # @return [Integer, nil] The attribute's max length, taken from its `length` validator, if any.
  def maximum_length
    object.class.validators_on(attribute_name).find { |validator| validator.kind == :length }&.options&.[](:maximum)
  end
end
