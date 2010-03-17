module Danbooru
  class CustomConfiguration < Configuration
    # Define your custom overloads here
    def app_name
      "f"
    end

    def posts_per_page
      1
    end
  end
end
