module BulkUpdateRequestsHelper
  def bur_script_example
    <<~BUR
      create alias bunny -> rabbit
      remove alias bunny -> rabbit

      create implication bunny -> animal
      remove implication bunny -> animal

      rename bunny -> rabbit

      update bunny_focus -> animal_focus bunny

      nuke bunny

      category touhou -> copyright
    BUR
  end
end
