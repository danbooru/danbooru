# frozen_string_literal: true

# This component is used to render a DText editor within a form.
class DtextEditorComponent < ApplicationComponent
  attr_reader :input_name, :form, :inline, :input_options

  # @param input_name [String] The name attribute for the <input> or <textarea> element.
  # @param form [SimpleForm::FormBuilder] The form builder instance.
  # @param inline [Boolean] Whether the editor should be a single-line <input> or a multi-line <textarea>
  # @param input_options [Hash] Additional HTML options for the <input> or <textarea> element.
  def initialize(input_name:, form:, inline: false, input_options: {})
    super
    @input_name = input_name
    @form = form
    @inline = inline
    @input_options = input_options
  end
end
