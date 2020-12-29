Rails.application.routes.draw do
  resources :posts, only: [:index, :show, :update, :destroy] do
    get :random, on: :collection
  end

  resources :autocomplete, only: [:index]

  # XXX This comes *after* defining posts above because otherwise the paginator
  # generates `/?page=2` instead of `/posts?page=2` on the posts#index page.
  root "posts#index"

  namespace :admin do
    resources :users, :only => [:edit, :update]
    resource  :dashboard, :only => [:show]
  end
  namespace :moderator do
    resource :dashboard, :only => [:show]
    resources :ip_addrs, :only => [:index] do
      collection do
        get :search
      end
    end
    namespace :post do
      resources :posts, :only => [:delete, :expunge, :confirm_delete] do
        member do
          post :expunge
          get :confirm_move_favorites
          post :move_favorites
          get :confirm_ban
          post :ban
          post :unban
        end
      end
    end
    resources :ip_addrs, :only => [:index, :search] do
      collection do
        get :search
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
      resource :email_notification, :only => [:show, :destroy]
      resource :deletion, :only => [:show, :destroy]
      resource :api_key, :only => [:show, :view, :update, :destroy] do
        post :view
      end
    end
  end

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
  resources :comment_votes, only: [:index]
  resources :comments do
    resource :votes, controller: "comment_votes", only: [:create, :destroy], as: "comment_votes"
    collection do
      get :search
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
  resources :delayed_jobs, :only => [:index, :destroy] do
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
  resources :forum_post_votes, only: [:index, :create, :destroy]
  resources :forum_topics do
    member do
      post :undelete
    end
    collection do
      post :mark_all_as_read
    end
  end
  resources :forum_topic_visits, only: [:index]
  resources :ip_bans, only: [:index, :new, :create, :update]
  resources :ip_addresses, only: [:show, :index], id: /.+?(?=\.json|\.xml|\.html)|.+/
  resource :iqdb_queries, :only => [:show, :create] do
    collection do
      get :preview
      get :check, to: redirect {|path_params, req| "/iqdb_queries?#{req.query_string}"}
    end
  end
  resources :mod_actions
  resources :moderation_reports, only: [:new, :create, :index, :show]
  resources :modqueue, only: [:index]
  resources :news_updates
  resources :notes do
    member do
      put :revert
    end
  end
  resources :note_versions, :only => [:index, :show]
  resource :note_previews, :only => [:show]
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
  resources :post_replacements, :only => [:index, :new, :create, :update]
  resources :post_votes, only: [:index]

  # XXX Use `only: []` to avoid redefining post routes defined at top of file.
  resources :posts, only: [] do
    resources :events, :only => [:index], :controller => "post_events"
    resources :replacements, :only => [:index, :new, :create], :controller => "post_replacements"
    resource :artist_commentary, :only => [:index, :show] do
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
  resources :post_approvals, only: [:create, :index]
  resources :post_disapprovals, only: [:create, :show, :index]
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
      get :search
    end
    member do
      put :revert
    end
  end
  resources :artist_commentary_versions, :only => [:index, :show]
  resource :related_tag, :only => [:show, :update]
  resources :recommended_posts, only: [:index]
  resources :robots, only: [:index]
  resources :saved_searches, :except => [:show]
  resource :session, only: [:new, :create, :destroy] do
    get :sign_out, on: :collection
  end
  resource :source, :only => [:show]
  resource :status, only: [:show], controller: "status"
  resources :tags
  resources :tag_aliases, only: [:show, :index, :destroy]
  resources :tag_implications, only: [:show, :index, :destroy]
  resources :uploads do
    collection do
      post :preprocess
      get :batch
      get :image_proxy
    end
  end
  resources :users do
    resources :favorite_groups, controller: "favorite_groups", only: [:index], as: "favorite_groups"
    resource :email, only: [:show, :edit, :update] do
      get :verify
      post :send_confirmation
    end
    resource :password, only: [:edit, :update]
    resource :api_key, :only => [:show, :view, :update, :destroy], :controller => "maintenance/user/api_keys" do
      post :view
    end

    collection do
      get :custom_style
    end
  end
  resources :user_upgrades, only: [:new, :create, :show, :index] do
    get :receipt, on: :member
    get :payment, on: :member
    put :refund, on: :member
  end
  resources :user_feedbacks, except: [:destroy]
  resources :user_name_change_requests, only: [:new, :create, :show, :index]
  resources :webhooks do
    post :receive, on: :collection
  end
  resources :wiki_pages, id: /.+?(?=\.json|\.xml|\.html)|.+/ do
    put :revert, on: :member
    get :search, on: :collection
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
  get "/static/keyboard_shortcuts" => "static#keyboard_shortcuts", :as => "keyboard_shortcuts"
  get "/static/bookmarklet" => "static#bookmarklet", :as => "bookmarklet"
  get "/static/site_map" => "static#site_map", :as => "site_map"
  get "/static/contact" => "static#contact", :as => "contact"
  get "/static/dtext_help" => "static#dtext_help", :as => "dtext_help"
  get "/static/terms_of_service", to: redirect("/terms_of_service")
  get "/user_upgrade/new", to: redirect("/user_upgrades/new")

  get "/mock/recommender/recommend/:user_id" => "mock_services#recommender_recommend", as: "mock_recommender_recommend"
  get "/mock/recommender/similiar/:post_id" => "mock_services#recommender_similar", as: "mock_recommender_similar"
  get "/mock/reportbooru/missed_searches" => "mock_services#reportbooru_missed_searches", as: "mock_reportbooru_missed_searches"
  get "/mock/reportbooru/post_searches/rank" => "mock_services#reportbooru_post_searches", as: "mock_reportbooru_post_searches"
  get "/mock/reportbooru/post_views/rank" => "mock_services#reportbooru_post_views", as: "mock_reportbooru_post_views"
  get "/mock/iqdbs/similar" => "mock_services#iqdbs_similar", as: "mock_iqdbs_similar"
  post "/mock/iqdbs/similar" => "mock_services#iqdbs_similar"

  match "*other", to: "static#not_found", via: :all
end
