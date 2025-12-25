# frozen_string_literal: true

# This component is used to render a DText editor within a form.
class DtextEditorComponent < ApplicationComponent
  attr_reader :input_name, :form, :editor_html, :input_html

  delegate :eye_icon, :bold_icon, :italic_icon, :strikethrough_icon, :underline_icon, :exclamation_icon, :search_icon,
           :folder_open_icon, :quote_icon, :code_icon, :double_brackets_icon, :no_double_brackets_icon, :horizontal_line_icon,
           :add_reaction_icon, to: :helpers

  # @param input_name [String] The name attribute for the <input> or <textarea> element.
  # @param form [SimpleForm::FormBuilder] The form builder instance.
  # @param editor_html [Hash] Additional HTML options for the <div class="dtext-editor"> wrapper element.
  # @param input_html [Hash] Additional HTML options for the <input> or <textarea> element.
  def initialize(input_name:, form:, editor_html: {}, input_html: {})
    super
    @input_name = input_name
    @form = form
    @editor_html = editor_html.to_h
    @input_html = input_html.to_h
  end

  # @return [DText] The DText object associated with the editor.
  def dtext
    form.object.send("dtext_#{input_name}")
  end

  # @return [Array<String>] The list of the current site's domain names. Used for determining which links belong to the current site.
  def domains
    [dtext.domain, *dtext.alternate_domains].compact_blank.uniq
  end

  # @return [Boolean] Whether the DText field is a single-line <input> or a multi-line <textarea>.
  def inline?
    dtext.inline
  end

  # @return [Boolean] Whether media embeds are enabled for the DText field.
  def media_embeds?
    dtext.media_embeds
  end
end
