# Allow Rails URL helpers to be used outside of views.
# Example: Routes.posts_path(tags: "touhou") => /posts?tags=touhou

class Routes
  include Singleton
  include Rails.application.routes.url_helpers

  class << self
    delegate_missing_to :instance
  end
end
