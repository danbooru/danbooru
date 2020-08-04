Rails.application.routes.draw do
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
  resources :autocomplete, only: [:index]
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
    collection do
      get :search
    end
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
  resources :posts, only: [:index, :show, :update, :destroy] do
    resources :events, :only => [:index], :controller => "post_events"
    resources :replacements, :only => [:index, :new, :create], :controller => "post_replacements"
    resource :artist_commentary, :only => [:index, :show] do
      collection { put :create_or_update }
      member { put :revert }
    end
    resource :votes, controller: "post_votes", only: [:create, :destroy], as: "post_votes"
    collection do
      get :random
    end
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
  resources :saved_searches, :except => [:show] do
    collection do
      get :labels
    end
  end
  resource :session, only: [:new, :create, :destroy] do
    get :sign_out, on: :collection
  end
  resource :source, :only => [:show]
  resources :tags do
    collection do
      get :autocomplete
    end
  end
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
      get :search
      get :custom_style
    end
  end
  resource :user_upgrade, :only => [:new, :create, :show]
  resources :user_feedbacks, except: [:destroy]
  resources :user_name_change_requests, only: [:new, :create, :show, :index]
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

  # legacy aliases
  get "/artist" => redirect {|params, req| "/artists?page=#{req.params[:page]}&search[name]=#{CGI.escape(req.params[:name].to_s)}"}
  get "/artist/index.xml", :controller => "legacy", :action => "artists", :format => "xml"
  get "/artist/index.json", :controller => "legacy", :action => "artists", :format => "json"
  get "/artist/index" => redirect {|params, req| "/artists?page=#{req.params[:page]}"}
  get "/artist/show/:id" => redirect("/artists/%{id}")
  get "/artist/show" => redirect {|params, req| "/artists?name=#{CGI.escape(req.params[:name].to_s)}"}
  get "/artist/history/:id" => redirect("/artist_versions?search[artist_id]=%{id}")
  get "/artist/recent_changes" => redirect("/artist_versions")

  get "/comment" => redirect {|params, req| "/comments?page=#{req.params[:page]}"}
  get "/comment/index" => redirect {|params, req| "/comments?page=#{req.params[:page]}"}
  get "/comment/show/:id" => redirect("/comments/%{id}")
  get "/comment/new" => redirect("/comments")
  get("/comment/search" => redirect do |params, req|
    if req.params[:query] =~ /^user:(.+)/i
      "/comments?group_by=comment&search[creator_name]=#{CGI.escape($1)}"
    else
      "/comments/search"
    end
  end)

  get "/favorite" => redirect {|params, req| "/favorites?page=#{req.params[:page]}"}
  get "/favorite/index" => redirect {|params, req| "/favorites?page=#{req.params[:page]}"}
  get "/favorite/list_users.json", :controller => "legacy", :action => "unavailable"

  get "/forum" => redirect {|params, req| "/forum_topics?page=#{req.params[:page]}"}
  get "/forum/index" => redirect {|params, req| "/forum_topics?page=#{req.params[:page]}"}
  get "/forum/show/:id" => redirect {|params, req| "/forum_posts/#{req.params[:id]}?page=#{req.params[:page]}"}
  get "/forum/search" => redirect("/forum_posts/search")

  get "/help/:title" => redirect {|params, req| "/wiki_pages?title=#{CGI.escape('help:' + req.params[:title])}"}

  get "/note" => redirect {|params, req| "/notes?page=#{req.params[:page]}"}
  get "/note/index" => redirect {|params, req| "/notes?page=#{req.params[:page]}"}
  get "/note/history" => redirect {|params, req| "/note_versions?search[updater_id]=#{req.params[:user_id]}"}

  get "/pool" => redirect {|params, req| "/pools?page=#{req.params[:page]}"}
  get "/pool/index" => redirect {|params, req| "/pools?page=#{req.params[:page]}"}
  get "/pool/show/:id" => redirect("/pools/%{id}")
  get "/pool/history/:id" => redirect("/pool_versions?search[pool_id]=%{id}")
  get "/pool/recent_changes" => redirect("/pool_versions")

  get "/post/index.xml", :controller => "legacy", :action => "posts", :format => "xml"
  get "/post/index.json", :controller => "legacy", :action => "posts", :format => "json"
  get "/post/piclens", :controller => "legacy", :action => "unavailable"
  get "/post/index" => redirect {|params, req| "/posts?tags=#{CGI.escape(req.params[:tags].to_s)}&page=#{req.params[:page]}"}
  get "/post" => redirect {|params, req| "/posts?tags=#{CGI.escape(req.params[:tags].to_s)}&page=#{req.params[:page]}"}
  get "/post/upload" => redirect("/uploads/new")
  get "/post/moderate" => redirect("/moderator/post/queue")
  get "/post/atom" => redirect {|params, req| "/posts.atom?tags=#{CGI.escape(req.params[:tags].to_s)}"}
  get "/post/atom.feed" => redirect {|params, req| "/posts.atom?tags=#{CGI.escape(req.params[:tags].to_s)}"}
  get "/post/popular_by_day" => redirect("/explore/posts/popular")
  get "/post/popular_by_week" => redirect("/explore/posts/popular")
  get "/post/popular_by_month" => redirect("/explore/posts/popular")
  get "/post/show/:id/:tag_title" => redirect("/posts/%{id}")
  get "/post/show/:id" => redirect("/posts/%{id}")
  get "/post/show" => redirect {|params, req| "/posts?md5=#{req.params[:md5]}"}
  get "/post/view/:id/:tag_title" => redirect("/posts/%{id}")
  get "/post/view/:id" => redirect("/posts/%{id}")
  get "/post/flag/:id" => redirect("/posts/%{id}")

  get("/post_tag_history" => redirect do |params, req|
    page = req.params[:before_id].present? ? "b#{req.params[:before_id]}" : req.params[:page]
    "/post_versions?page=#{page}&search[updater_id]=#{req.params[:user_id]}"
  end)
  get "/post_tag_history/index" => redirect {|params, req| "/post_versions?page=#{req.params[:page]}&search[post_id]=#{req.params[:post_id]}"}

  get "/tag/index.xml", :controller => "legacy", :action => "tags", :format => "xml"
  get "/tag/index.json", :controller => "legacy", :action => "tags", :format => "json"
  get "/tag" => redirect {|params, req| "/tags?page=#{req.params[:page]}&search[name_matches]=#{CGI.escape(req.params[:name].to_s)}&search[order]=#{req.params[:order]}&search[category]=#{req.params[:type]}"}
  get "/tag/index" => redirect {|params, req| "/tags?page=#{req.params[:page]}&search[name_matches]=#{CGI.escape(req.params[:name].to_s)}&search[order]=#{req.params[:order]}"}

  get "/tag_implication" => redirect {|params, req| "/tag_implications?search[name_matches]=#{CGI.escape(req.params[:query].to_s)}"}

  get "/user/index.xml", :controller => "legacy", :action => "users", :format => "xml"
  get "/user/index.json", :controller => "legacy", :action => "users", :format => "json"
  get "/user" => redirect {|params, req| "/users?page=#{req.params[:page]}"}
  get "/user/index" => redirect {|params, req| "/users?page=#{req.params[:page]}"}
  get "/user/show/:id" => redirect("/users/%{id}")
  get "/user/login" => redirect("/sessions/new")
  get "/user_record" => redirect {|params, req| "/user_feedbacks?search[user_id]=#{req.params[:user_id]}"}
  get "/login", to: "sessions#new", as: :login
  get "/logout", to: "sessions#sign_out", as: :logout
  get "/profile", to: "users#profile", as: :profile
  get "/settings", to: "users#settings", as: :settings

  get "/wiki" => redirect {|params, req| "/wiki_pages?page=#{req.params[:page]}"}
  get "/wiki/index" => redirect {|params, req| "/wiki_pages?page=#{req.params[:page]}"}
  get "/wiki/rename" => redirect("/wiki_pages")
  get "/wiki/show" => redirect {|params, req| "/wiki_pages?title=#{CGI.escape(req.params[:title].to_s)}"}
  get "/wiki/recent_changes" => redirect {|params, req| "/wiki_page_versions?search[updater_id]=#{req.params[:user_id]}"}
  get "/wiki/history/:title" => redirect("/wiki_page_versions?title=%{title}")

  get "/sitemap" => "static#sitemap_index"
  get "/opensearch" => "static#opensearch", :as => "opensearch"
  get "/privacy" => "static#privacy_policy", :as => "privacy_policy"
  get "/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  get "/static/keyboard_shortcuts" => "static#keyboard_shortcuts", :as => "keyboard_shortcuts"
  get "/static/bookmarklet" => "static#bookmarklet", :as => "bookmarklet"
  get "/static/site_map" => "static#site_map", :as => "site_map"
  get "/static/contact" => "static#contact", :as => "contact"
  get "/static/dtext_help" => "static#dtext_help", :as => "dtext_help"
  get "/static/terms_of_service" => redirect { "/terms_of_service" }

  get "/mock/recommender/recommend/:user_id" => "mock_services#recommender_recommend", as: "mock_recommender_recommend"
  get "/mock/recommender/similiar/:post_id" => "mock_services#recommender_similar", as: "mock_recommender_similar"
  get "/mock/reportbooru/missed_searches" => "mock_services#reportbooru_missed_searches", as: "mock_reportbooru_missed_searches"
  get "/mock/reportbooru/post_searches/rank" => "mock_services#reportbooru_post_searches", as: "mock_reportbooru_post_searches"
  get "/mock/reportbooru/post_views/rank" => "mock_services#reportbooru_post_views", as: "mock_reportbooru_post_views"
  get "/mock/iqdbs/similar" => "mock_services#iqdbs_similar", as: "mock_iqdbs_similar"
  post "/mock/iqdbs/similar" => "mock_services#iqdbs_similar"

  root :to => "posts#index"

  get "*other", :to => "static#not_found"
end
