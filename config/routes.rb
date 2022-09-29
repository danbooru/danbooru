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
    resource :dashboard, :only => [:show]
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
        get :curated
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
      resource :deletion, :only => [:show, :destroy]
    end
  end

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
  resources :artist_versions, :only => [:index, :show] do
    collection do
      get :search
    end
  end
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
  resources :counts do
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
      get :check, to: redirect {|path_params, req| "/iqdb_queries?#{req.query_string}"}
    end
  end
  resources :media_assets, only: [:index, :show]
  resources :media_metadata, only: [:index]

  resources :ai_tags, only: [:index]
  put "/ai_tags/:media_asset_id/:tag_id/tag", to: "ai_tags#tag", as: "tag_ai_tag"

  resources :mod_actions
  resources :moderation_reports, only: [:new, :create, :index, :show, :update]
  resources :modqueue, only: [:index]
  resources :news_updates
  resources :notes do
    member do
      put :revert
    end
  end
  resources :note_versions, :only => [:index, :show]
  resource :note_previews, only: [:create, :show]
  resource :password_reset, only: [:create, :show]
  resources :pixiv_ugoira_frame_data, only: [:index]
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
    resource :artist_commentary, only: [:show] do
      collection { put :create_or_update }
      member { put :revert }
    end
    resource :votes, controller: "post_votes", only: [:create, :destroy], as: "post_votes"
    member do
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
  resources :robots, only: [:index]
  resources :saved_searches, :except => [:show]
  resource :session, only: [:new, :create, :destroy] do
    get :confirm_password, on: :collection
    get :sign_out, on: :collection
  end
  resource :source, :only => [:show]
  resource :status, only: [:show], controller: "status"
  resources :tags
  resources :tag_aliases, only: [:show, :index, :destroy]
  resources :tag_implications, only: [:show, :index, :destroy]
  resources :tag_versions, only: [:index, :show]

  get "/redeem", to: "upgrade_codes#redeem", as: "redeem_upgrade_codes"
  resources :upgrade_codes, only: [:create, :index] do
    get :redeem, on: :collection
    post :upgrade, on: :collection
  end

  resources :uploads do
    collection do
      get :batch, to: redirect(path: "/uploads/new")
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
    resources :api_keys, only: [:new, :create, :edit, :update, :index, :destroy]
    resources :uploads, only: [:index]

    collection do
      get :custom_style
    end
  end
  get "/upgrade", to: "user_upgrades#new", as: "new_user_upgrade"
  get "/user_upgrades/new", to: redirect("/upgrade")
  resources :user_upgrades, only: [:new, :create, :show, :index] do
    get :receipt, on: :member
    get :payment, on: :member
    put :refund, on: :member
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

  # Legacy Danbooru 1 API endpoints
  get "/tag/index.xml", :controller => "legacy", :action => "tags", :format => "xml"
  get "/tag/index.json", :controller => "legacy", :action => "tags", :format => "json"
  get "/post/index.xml", :controller => "legacy", :action => "posts", :format => "xml"
  get "/post/index.json", :controller => "legacy", :action => "posts", :format => "json"

  # Legacy Danbooru 1 redirects.
  get "/artist" => redirect {|params, req| "/artists?page=#{req.params[:page]}&search[name]=#{CGI.escape(req.params[:name].to_s)}"}
  get "/artist/show/:id" => redirect("/artists/%{id}")
  get "/artist/show" => redirect {|params, req| "/artists?name=#{CGI.escape(req.params[:name].to_s)}"}

  get "/forum" => redirect {|params, req| "/forum_topics?page=#{req.params[:page]}"}
  get "/forum/show/:id" => redirect {|params, req| "/forum_posts/#{req.params[:id]}?page=#{req.params[:page]}"}

  get "/pool/show/:id" => redirect("/pools/%{id}")

  get "/post/index" => redirect {|params, req| "/posts?tags=#{CGI.escape(req.params[:tags].to_s)}&page=#{req.params[:page]}"}
  get "/post/atom" => redirect {|params, req| "/posts.atom?tags=#{CGI.escape(req.params[:tags].to_s)}"}
  get "/post/show/:id/:tag_title" => redirect("/posts/%{id}")
  get "/post/show/:id" => redirect("/posts/%{id}")

  get "/tag" => redirect {|params, req| "/tags?page=#{req.params[:page]}&search[name_matches]=#{CGI.escape(req.params[:name].to_s)}&search[order]=#{req.params[:order]}&search[category]=#{req.params[:type]}"}
  get "/tag/index" => redirect {|params, req| "/tags?page=#{req.params[:page]}&search[name_matches]=#{CGI.escape(req.params[:name].to_s)}&search[order]=#{req.params[:order]}"}

  get "/user/show/:id" => redirect("/users/%{id}")

  get "/wiki/show" => redirect {|params, req| "/wiki_pages?title=#{CGI.escape(req.params[:title].to_s)}"}
  get "/help/:title" => redirect {|params, req| "/wiki_pages?title=#{CGI.escape('help:' + req.params[:title])}"}

  get "/login", to: "sessions#new", as: :login
  get "/logout", to: "sessions#sign_out", as: :logout
  get "/profile", to: "users#profile", as: :profile
  get "/settings", to: "users#settings", as: :settings

  get "/sitemap" => "static#sitemap_index"
  get "/opensearch" => "static#opensearch", :as => "opensearch"
  get "/privacy" => "static#privacy_policy", :as => "privacy_policy"
  get "/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  get "/404" => "static#not_found", :as => "not_found"
  get "/2257" => "static#2257", :as => "usc_2257"
  get "/contact" => "static#contact", :as => "contact"

  get "/static/keyboard_shortcuts" => "static#keyboard_shortcuts", :as => "keyboard_shortcuts"
  get "/static/bookmarklet" => "static#bookmarklet", :as => "bookmarklet"
  get "/static/site_map" => "static#site_map", :as => "site_map"
  get "/static/colors" => "static#colors", :as => "colors"
  get "/static/dtext_help" => "static#dtext_help", :as => "dtext_help"
  get "/static/terms_of_service", to: redirect("/terms_of_service")
  get "/static/contact", to: redirect("/contact")
  get "/user_upgrade/new", to: redirect("/upgrade")
  get "/delayed_jobs", to: redirect("/jobs")

  get "/mock/recommender/recommend/:user_id" => "mock_services#recommender_recommend", as: "mock_recommender_recommend"
  get "/mock/recommender/similiar/:post_id" => "mock_services#recommender_similar", as: "mock_recommender_similar"
  get "/mock/reportbooru/missed_searches" => "mock_services#reportbooru_missed_searches", as: "mock_reportbooru_missed_searches"
  get "/mock/reportbooru/post_searches/rank" => "mock_services#reportbooru_post_searches", as: "mock_reportbooru_post_searches"
  get "/mock/reportbooru/post_views/rank" => "mock_services#reportbooru_post_views", as: "mock_reportbooru_post_views"
  get "/mock/iqdb/query" => "mock_services#iqdb_query", as: "mock_iqdb_query"
  post "/mock/iqdb/query" => "mock_services#iqdb_query"
  get "/mock/autotagger/evaluate" => "mock_services#autotagger_evaluate", as: "mock_autotagger_evaluate"

  match "*other", to: "static#not_found", via: :all
end
