# frozen_string_literal: true

require "test_helper"

module Sources
  class GoogleTest < ActiveSupport::TestCase
    context "Google:" do
      context "A lh3.googleusercontent.com sample image URL" do
        strategy_should_work(
          "https://lh3.googleusercontent.com/qAhRBhfciCcosUoYHPJr5WtNYSJ81vpSqcQwbQitZtsR3mB2aCUj7J5LvhJOCfWn-CWqiLB18SyTr1VJvm_HI7B72opIAMZiZvg=s400",
          image_urls: %w[https://lh3.googleusercontent.com/qAhRBhfciCcosUoYHPJr5WtNYSJ81vpSqcQwbQitZtsR3mB2aCUj7J5LvhJOCfWn-CWqiLB18SyTr1VJvm_HI7B72opIAMZiZvg=d],
          media_files: [{ file_size: 2_797_670 }],
          page_url: nil
        )
      end
    end
  end
end
