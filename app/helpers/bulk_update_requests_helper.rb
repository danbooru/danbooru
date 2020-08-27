module BulkUpdateRequestsHelper
  def bur_script_example
    <<~EOS
      create alias bunny -> rabbit
      remove alias bunny -> rabbit

      create implication bunny -> animal
      remove implication bunny -> animal

      rename bunny -> rabbit

      category touhou -> copyright
    EOS
  end
end
