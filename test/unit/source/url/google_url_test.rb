require "test_helper"

module Source::Tests::URL
  class GoogleUrlTest < ActiveSupport::TestCase
    context "Google URLs" do
      should be_image_url(
        "https://lh3.googleusercontent.com/qAhRBhfciCcosUoYHPJr5WtNYSJ81vpSqcQwbQitZtsR3mB2aCUj7J5LvhJOCfWn-CWqiLB18SyTr1VJvm_HI7B72opIAMZiZvg=s400",
      )
    end
  end
end
