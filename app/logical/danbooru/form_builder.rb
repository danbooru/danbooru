# frozen_string_literal: true

module Danbooru
  # The form builder used by `edit_form_for`. Adds standard form buttons.
  class FormBuilder < SimpleForm::FormBuilder
    # Build a primary submit button.
    #
    # @param label [String, nil] a fixed label, used for both new and existing records
    # @param create [String] the label for new records
    # @param update [String] the label for existing records
    # @param options [Hash] options passed to `submit`
    def submit_button(label = nil, create: "Create", update: "Update", **options)
      label ||= object.try(:persisted?) ? update : create
      submit(label, class: "button-primary", **options)
    end

    # Build a cancel button. The page's Javascript handles the click.
    #
    # @param label [String] the button label
    # @param options [Hash] options passed to `button`
    def cancel_button(label = "Cancel", **options)
      button(:button, label, type: :button, name: :cancel, class: "button-outline-primary", **options)
    end
  end
end
