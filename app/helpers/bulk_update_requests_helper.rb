module BulkUpdateRequestsHelper
  def bur_script_example
    <<~EOS
      create alias kitty -> cat
      remove alias kitty -> cat

      create implication cat -> animal
      remove implication cat -> animal

      mass update kitty -> cat
      category touhou -> copyright
    EOS
  end
end
