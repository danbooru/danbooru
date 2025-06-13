# frozen_string_literal: true

# This component is used to render a DText editor within a form.
class DtextEditorComponent < ApplicationComponent
  attr_reader :input_name, :form, :input_options

  delegate :eye_icon, :bold_icon, :italic_icon, :strikethrough_icon, :underline_icon, :quote_icon, to: :helpers

  # @param input_name [String] The name attribute for the <input> or <textarea> element.
  # @param form [SimpleForm::FormBuilder] The form builder instance.
  # @param input_options [Hash] Additional HTML options for the <input> or <textarea> element.
  def initialize(input_name:, form:, input_options: {})
    super
    @input_name = input_name
    @form = form
    @input_options = input_options
  end

  # @return [Boolean] Whether the DText field is a single-line <input> or a multi-line <textarea>.
  def inline?
    form.object.send("dtext_#{input_name}").inline
  end

  # @return [Boolean] Whether media embeds are enabled for the DText field.
  def media_embeds?
    form.object.send("dtext_#{input_name}").media_embeds
  end
end
