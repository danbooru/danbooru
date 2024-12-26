# This file contains configuration for Danbooru's URL routes. It defines all the
# URL endpoints and HTTP redirects used by Danbooru.
#
# A list of routes can be found at http://localhost:3000/rails/info/routes when
# running the server in development mode. You can also run `bin/rails routes` to
# produce a list of routes.
#
# @see https://guides.rubyonrails.org/routing.html
# @see http://localhost:3000/rails/info/routes
Rails.application.routes.draw do
  resources :posts, only: [:index, :show, :update, :destroy, :new, :create] do
    get :random, on: :collection
  end

  resources :autocomplete, only: [:index]

  # XXX This comes *after* defining posts above because otherwise the paginator
  # generates `/?page=2` instead of `/posts?page=2` on the posts#index page.
  root "posts#index"

  namespace :admin do
    resources :users, :only => [:edit, :update]
  end
  namespace :moderator do
    namespace :post do
      resources :posts, :only => [:delete, :expunge, :confirm_delete] do
        member do
          post :expunge
          get :confirm_move_favorites
          post :move_favorites
          post :ban
          post :unban
        end
      end
    end
  end
  namespace :explore do
    resources :posts, :only => [] do
      collection do
        get :popular
        get :viewed
        get :searches
        get :missed_searches
      end
    end
  end
  namespace :maintenance do
    namespace :user do
      resource :count_fixes, only: [:new, :create]
      resource :email_notification, only: [:show, :create, :destroy]
    end
  end

  resources :ai_metadata, only: [:index, :show] do
    get :stealth, on: :collection, to: "prompt_protector#index"
  end
  resources :ai_metadata_versions, only: [:index, :show]
  resources :api_keys, only: [:new, :create, :edit, :update, :index, :destroy]

  resources :artists do
    member do
      put :revert
      put :ban
      put :unban
    end
    collection do
      get :show_or_new
      get :banned
    end
  end
  resources :artist_urls, only: [:index]
  resources :artist_versions, only: [:index, :show]
  resources :bans
  resources :bulk_update_requests do
    member do
      post :approve
    end
  end
  resources :comment_votes, only: [:index, :show, :destroy]
  resources :comments do
    resource :votes, controller: "comment_votes", only: [:create, :destroy], as: "comment_votes" do
      get "/", action: :index
    end
    collection do
      get :search, to: redirect("/comments?group_by=comment")
    end
    member do
      post :undelete
    end
  end
  resources :counts, only: [] do
    collection do
      get :posts
    end
  end
  resources :jobs, only: [:index, :destroy] do
    member do
      put :run
      put :retry
      put :cancel
    end
  end
  resources :dmails, :only => [:new, :create, :update, :index, :show] do
    collection do
      get :all
      post :mark_all_as_read
    end
  end
  resource  :dtext_preview, :only => [:create]
  resources :dtext_links, only: [:index]
  resources :emails, only: [:index, :show]
  resources :favorites, :only => [:index, :create, :destroy]
  resources :favorite_groups do
    member do
      put :add_post
      put :remove_post
    end
    resource :order, :only => [:edit], :controller => "favorite_group_orders"
  end
  resources :forum_posts do
    member do
      post :undelete
    end
    collection do
      get :search
    end
  end
  resources :forum_post_votes, only: [:index, :show, :create, :destroy]
  resources :forum_topics do
    member do
      post :undelete
    end
    collection do
      post :mark_all_as_read
    end
  end
  resources :forum_topic_visits, only: [:index]
  resources :ip_bans, only: [:index, :show, :new, :create, :update]
  resources :ip_addresses, only: [:show], id: /.+?(?=\.json|\.xml|\.html)|.+/
  resources :ip_geolocations, only: [:index]
  resource :iqdb_queries, :only => [:show, :create] do
    collection do
      get :preview
    end
  end
  resources :media_assets, only: [:index, :show, :destroy] do
    get :metadata
    get "/:variant", to: "media_assets#image", as: :image
  end
  resources :media_metadata, only: [:index]

  resources :metrics, only: [:index], defaults: { format: :text } do
    get "/instance", on: :collection, to: "metrics#instance", as: :instance
  end

  resources :ai_tags, only: [:index]
  put "/ai_tags/:media_asset_id/:tag_id/tag", to: "ai_tags#tag", as: "tag_ai_tag"

  resources :mod_actions
  get "/moderator/dashboard" => "moderator_dashboard#show"
  resources :moderation_reports, only: [:new, :create, :index, :show, :update]
  resources :modqueue, only: [:index]
  resources :news_updates do
    member do
      post :undelete
    end
  end
  resources :notes do
    member do
      put :revert
    end
  end
  resources :note_versions, :only => [:index, :show]
  resource :note_previews, only: [:create, :show]
  resource :password_reset, only: [:create, :show, :edit, :update]
  resource :password, only: [:edit, :update]
  resources :pools do
    member do
      put :revert
      post :undelete
    end
    collection do
      get :gallery
    end
    resource :order, :only => [:edit], :controller => "pool_orders"
  end
  resource :pool_element, :only => [:create]
  resources :pool_versions, :only => [:index] do
    member do
      get :diff
    end
    collection do
      get :search
    end
  end
  resources :post_events, only: [:index]
  resources :post_regenerations, :only => [:create]
  resources :post_replacements, only: [:index, :show, :new, :create, :update]
  resources :post_votes, only: [:index, :show, :create, :destroy]

  # XXX Use `only: []` to avoid redefining post routes defined at top of file.
  resources :posts, only: [] do
    resources :events, only: [:index], controller: "post_events", as: "post_events"
    resources :favorites, only: [:index, :create, :destroy]
    resources :replacements, :only => [:index, :new, :create], :controller => "post_replacements"
    resource :ai_metadata, only: [:show] do
      collection { put :create_or_update }
      member do
        put :revert
        put :undo
      end
    end
    resource :artist_commentary, only: [:show] do
      collection { put :create_or_update }
      member { put :revert }
    end
    resource :votes, controller: "post_votes", only: [:create, :destroy], as: "post_votes"
    member do
      post :view
      put :revert
      put :copy_notes
      get :show_seq
      put :mark_as_translated
    end
    get :similar, :to => "iqdb_queries#index"
  end
  resources :post_appeals
  resources :post_flags
  resources :post_approvals, only: [:create, :index, :show]
  resources :post_disapprovals
  resources :post_versions, :only => [:index, :search] do
    member do
      put :undo
    end
    collection do
      get :search
    end
  end
  resources :artist_commentaries, :only => [:index, :show] do
    collection do
      put :create_or_update
    end
    member do
      put :revert
    end
  end
  resources :artist_commentary_versions, :only => [:index, :show]
  resources :rate_limits, only: [:index]
  resource :related_tag, :only => [:show, :update]
  resources :recommended_posts, only: [:index]
  resources :reports, only: [:index, :show]
  resources :robots, only: [:index]
  resources :saved_searches, :except => [:show]
  resource :session, only: [:new, :create, :destroy] do
    post :verify_totp, on: :collection
    post :reauthenticate, on: :collection
    get :confirm_password, on: :collection
  end
  resource :source, :only => [:show]
  resource :status, only: [:show], controller: "status"
  resource :stats, only: [:show], controller: "statistics" do
    collection do
      post :purge_cache
    end
  end
  resources :tags
  resources :tag_aliases, only: [:show, :index, :destroy]
  resources :tag_implications, only: [:show, :index, :destroy]
  resources :tag_versions, only: [:index, :show]

  resources :uploads do
    collection do
      get :batch, to: redirect(path: "/uploads/new")
    end
    member do
      post :undelete
    end
    resources :upload_media_assets, only: [:show, :index], path: "assets"
  end
  resources :upload_media_assets, only: [:show, :index]
  resources :user_actions, only: [:index, :show]
  resources :users do
    resources :actions, only: [:index]
    resources :favorites, only: [:index, :create, :destroy]
    resources :favorite_groups, controller: "favorite_groups", only: [:index], as: "favorite_groups"
    resource :email, only: [:show, :edit, :update] do
      get :verify
      post :send_confirmation
    end
    resource :password, only: [:edit, :update]
    resource :totp, only: [:edit, :update, :destroy]
    resources :backup_codes, only: [:index, :create]
    resources :api_keys, only: [:new, :create, :edit, :update, :index, :destroy]
    resources :uploads, only: [:index]
    resources :user_events, only: [:index], path: "events"

    get :change_name, on: :member, to: "user_name_change_requests#new"
    get :custom_style, on: :collection
    get :deactivate, on: :member     # /users/:id/deactivate
    get :deactivate, on: :collection # /users/deactivate
  end
  resources :user_events, only: [:index]
  resources :user_feedbacks, except: [:destroy]
  resources :user_sessions, only: [:index]
  resources :user_name_change_requests, only: [:new, :create, :show, :index]
  resources :webhooks do
    post :receive, on: :collection
    post :authorize_net, on: :collection
  end
  resources :wiki_pages, id: /.+?(?=\.json|\.xml|\.html)|.+/ do
    put :revert, on: :member
    get :show_or_new, on: :collection
  end
  resources :wiki_page_versions, :only => [:index, :show, :diff] do
    collection do
      get :diff
    end
  end
  resource :dmca, only: [:create, :show] do
    get :template
  end

  get "/phsw3.js" => "service_worker#service_worker_js"

  get "/login", to: "sessions#new", as: :login
  get "/logout", to: "sessions#logout", as: :logout
  get "/profile", to: "users#profile", as: :profile
  get "/settings", to: "users#settings", as: :settings

  get "/up" => "health#show", as: :rails_health_check
  get "/up/postgres" => "health#postgres"
  get "/up/redis" => "health#redis"
  get "/sitemap" => "static#sitemap_index"
  get "/opensearch" => "static#opensearch", :as => "opensearch"
  get "/privacy" => "static#privacy_policy", :as => "privacy_policy"
  get "/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  get "/404" => "static#not_found", :as => "not_found"
  get "/2257" => "static#2257", :as => "usc_2257"
  get "/contact" => "static#contact", :as => "contact"
  get "/.well-known/change-password", to: redirect("/password/edit", status: 302)

  get "/static/keyboard_shortcuts" => "static#keyboard_shortcuts", :as => "keyboard_shortcuts"
  get "/static/bookmarklet" => "static#bookmarklet", :as => "bookmarklet"
  get "/static/site_map" => "static#site_map", :as => "site_map"
  get "/static/colors" => "static#colors", :as => "colors"
  get "/static/dtext_help" => "static#dtext_help", :as => "dtext_help"
  get "/static/terms_of_service", to: redirect("/terms_of_service")
  get "/static/contact", to: redirect("/contact")

  get "/mock/recommender/recommend/:user_id" => "mock_services#recommender_recommend", as: "mock_recommender_recommend"
  get "/mock/recommender/similiar/:post_id" => "mock_services#recommender_similar", as: "mock_recommender_similar"
  get "/mock/reportbooru/missed_searches" => "mock_services#reportbooru_missed_searches", as: "mock_reportbooru_missed_searches"
  get "/mock/reportbooru/post_searches/rank" => "mock_services#reportbooru_post_searches", as: "mock_reportbooru_post_searches"
  get "/mock/reportbooru/post_views/rank" => "mock_services#reportbooru_post_views", as: "mock_reportbooru_post_views"
  get "/mock/iqdb/query" => "mock_services#iqdb_query", as: "mock_iqdb_query"
  post "/mock/iqdb/query" => "mock_services#iqdb_query"
  get "/mock/autotagger/evaluate" => "mock_services#autotagger_evaluate", as: "mock_autotagger_evaluate"


  match "/", to: "static#not_found", via: %i[post put patch delete trace]
  match "*other", to: "static#not_found", via: :all
end
