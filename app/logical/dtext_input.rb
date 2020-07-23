# A custom SimpleForm input for DText fields.
#
# Usage:
#
#   <%= f.input :body, as: :dtext %>
#   <%= f.input :reason, as: :dtext, inline: true %>
#
# https://github.com/heartcombo/simple_form/wiki/Custom-inputs-examples
# https://github.com/heartcombo/simple_form/blob/master/lib/simple_form/inputs/string_input.rb
# https://github.com/heartcombo/simple_form/blob/master/lib/simple_form/inputs/text_input.rb

class DtextInput < SimpleForm::Inputs::Base
  enable :placeholder, :maxlength, :minlength

  def input(wrapper_options)
    t = template
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)

    t.tag.div(class: "dtext-previewable") do
      if options[:inline]
        t.concat @builder.text_field(attribute_name, merged_input_options)
      else
        t.concat @builder.text_area(attribute_name, { rows: 20, cols: 30 }.merge(merged_input_options))
      end

      t.concat t.tag.div(id: "dtext-preview", class: "dtext-preview prose")
      t.concat t.tag.span(t.link_to("Formatting help", t.dtext_help_path, remote: true, method: :get), class: "hint dtext-hint")
    end
  end
end
