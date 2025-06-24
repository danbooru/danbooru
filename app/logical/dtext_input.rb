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
  enable :placeholder, :maxlength, :minlength

  def initialize(...)
    super
    options[:label] = false unless options[:label].present? || object.send("dtext_#{attribute_name}").inline
    options[:wrapper_html] ||= {}
    options[:wrapper_html][:class] = "@container #{options[:wrapper_html][:class]}"
  end

  def input(wrapper_options)
    t = template
    input_options = merge_wrapper_options(input_html_options, wrapper_options)

    t.render(DtextEditorComponent.new(input_name: attribute_name, form: @builder, editor_html: options[:editor_html], input_html: input_options))
  end
end
