import every from "lodash/every";

// Enforce client-side validation on forms. This makes it so that forms with the `data-validate-form` attribute can't be
// submitted until all form fields are valid.
//
// This relies on HTML5 validation attributes (e.g. `required`, `minlength`, `maxlength`, `pattern`, etc) to specify the
// requirements for each field.
//
// https://developer.mozilla.org/en-US/docs/Learn/Forms/Form_validation
export default class FormValidator {
  static initialize() {
    $("form[data-validate-form]").toArray().forEach(element => {
      new FormValidator(element);
    });
  }

  constructor(form) {
    this.$form = $(form);
    this.$form.on("input.danbooru paste.danbooru", e => this.onInput(e));
    this.$form.on("submit.danbooru", e => this.onSubmit(e));
    this.onInput();
  }

  // Return true if all form fields are valid, or false if any fields are invalid.
  valid() {
    // XXX If the form has a captcha, don't allow submitting the form until the captcha has been completed.
    if (this.$form.find("div.cf-turnstile").length && !this.$form.find('input[name="cf-turnstile-response"]').val()) {
      return false;
    } else {
      return every(this.$form.find("input").toArray(), input => input.validity.valid);
    }
  }

  // Disable the submit button until all fields are valid.
  onInput() {
    this.$form.find('input[type="submit"]').prop('disabled', !this.valid());
  }

  // Disable submitting the form with the enter key until the form is valid.
  onSubmit(event) {
    if (!this.valid()) {
      event.preventDefault();
    }
  }
}

// XXX: Trigger form validation when a captcha is completed. See `captcha_tag` in app/logical/captcha_service.rb.
window.onCaptchaComplete = function() {
  $("form[data-validate-form]").trigger("input");
}

$(FormValidator.initialize);
