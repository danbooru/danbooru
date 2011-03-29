module Danbooru
  class CustomConfiguration < Configuration
    # Define your custom overloads here
    def app_name
      "."
    end

    def posts_per_page
      20
    end

    def is_user_restricted?(user)
      !user.is_privileged? || user.name == "ppayne"
    end

    def is_post_restricted?(post)
      post.has_tag?("loli") || post.has_tag?("shota")
    end

    def custom_html_header_content
      %{
        <script type="text/javascript">
          //var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
          //document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
        </script>
        <script type="text/javascript">
          try {
            //var pageTracker = _gat._getTracker("UA-86094-4");
            //pageTracker._trackPageview();
          } catch(err) {}
        </script>
      }.html_safe
    end
    
    def is_user_advertiser?(user)
      user.is_admin? || user.name == "ppayne"
    end
  end
end
