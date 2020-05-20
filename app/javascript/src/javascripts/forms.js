import Rails from '@rails/ujs';

let Form = {};

Form.initialize_autosubmit = function() {
  $(document).on("change", "form[data-autosubmit]", function(e) {
    Rails.fire(this, "submit");
  });
};

$(document).ready(Form.initialize_autosubmit);

export default Form;
