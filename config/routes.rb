Rails.application.routes.draw do

  namespace :admin do
    resources :users, :only => [:edit, :update]
    resource  :alias_and_implication_import, :only => [:new, :create]
    resource  :dashboard, :only => [:show]
  end
  namespace :mobile do
    resources :posts, :only => [:index, :show]
  end
  namespace :moderator do
    resource :bulk_revert, :only => [:new, :create]
    resource :dashboard, :only => [:show]
    resources :ip_addrs, :only => [:index] do
      collection do
        get :search
      end
    end
    resources :invitations, :only => [:new, :create, :index]
    resource :tag, :only => [:edit, :update]
    namespace :post do
      resource :queue, :only => [:show] do
        member do
          get :random
        end
      end
      resource :approval, :only => [:create]
      resource :disapproval, :only => [:create]
      resources :posts, :only => [:delete, :undelete, :expunge, :confirm_delete] do
        member do
          get :confirm_delete
          post :expunge
          post :replace
          post :delete
          post :undelete
          get :confirm_move_favorites
          post :move_favorites
          get :confirm_ban
          post :ban
          post :unban
        end
      end
    end
    resources :invitations, :only => [:new, :create, :index, :show]
    resources :ip_addrs, :only => [:index, :search] do
      collection do
        get :search
      end
    end
  end
  namespace :explore do
    resources :posts do
      collection do
        get :popular
        get :searches
        get :missed_searches
        get :hot
        get :intro
      end
    end
  end
  namespace :maintenance do
    namespace :user do
      resource :email_notification, :only => [:show, :destroy]
      resource :password_reset, :only => [:new, :create, :edit, :update]
      resource :login_reminder, :only => [:new, :create]
      resource :deletion, :only => [:show, :destroy]
      resource :email_change, :only => [:new, :create]
      resource :dmail_filter, :only => [:edit, :update]
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
      post :undelete
    end
    collection do
      get :show_or_new
      get :banned
      get :finder
    end
  end
  resources :artist_versions, :only => [:index] do
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
  resources :comments do
    resource :votes, :controller => "comment_votes", :only => [:create, :destroy]
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
  resources :dmails, :only => [:new, :create, :index, :show, :destroy] do
    collection do
      get :search
      post :mark_all_as_read
    end
  end
  resource  :dtext_preview, :only => [:create]
  resources :favorites
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
  resources :forum_topics do
    member do
      post :undelete
      get :new_merge
      post :create_merge
      post :subscribe
      post :unsubscribe
    end
    collection do
      post :mark_all_as_read
    end
    resource :visit, :controller => "forum_topic_visits"
  end
  resources :ip_bans
  resources :iqdb_queries, :only => [:create, :index]
  resources :janitor_trials do
    collection do
      get :test
    end
    member do
      put :promote
      put :demote
    end
  end
  resources :jobs
  resources :mod_actions
  resources :news_updates
  resources :notes do
    collection do
      get :search
    end
    member do
      put :revert
    end
  end
  resources :note_versions, :only => [:index]
  resource :note_previews, :only => [:show]
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
  resource  :pool_element, :only => [:create, :destroy] do
    collection do
      get :all_select
    end
  end
  resources :pool_versions, :only => [:index] do
    member do
      get :diff
    end
  end
  resources :posts do
    resources :events, :only => [:index], :controller => "post_events"
    resource :artist_commentary, :only => [:index, :show] do
      collection { put :create_or_update }
      member { put :revert }
    end
    resource :votes, :controller => "post_votes", :only => [:create, :destroy]
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
  resources :artist_commentary_versions, :only => [:index]
  resource :related_tag, :only => [:show, :update]
  get "reports/uploads" => "reports#uploads"
  get "reports/similar_users" => "reports#similar_users"
  get "reports/upload_tags" => "reports#upload_tags"
  get "reports/post_versions" => "reports#post_versions"
  post "reports/post_versions_create" => "reports#post_versions_create"
  resources :saved_searches, :except => [:show] do
    collection do
      get :labels
    end
  end
  resource :session do
    collection do
      get :sign_out
    end
  end
  resource :source, :only => [:show]
  resources :super_voters, :only => [:index]
  resources :tags do
    resource :correction, :only => [:new, :create, :show], :controller => "tag_corrections"
    collection do
      get :autocomplete
    end
  end
  resources :tag_aliases do
    resource :correction, :controller => "tag_alias_corrections"
    member do
      post :approve
    end
  end
  resource :tag_alias_request, :only => [:new, :create]
  resources :tag_implications do
    member do
      post :approve
    end
  end
  resource :tag_implication_request, :only => [:new, :create]
  resources :tag_subscriptions do
    member do
      post :migrate
      get :posts
    end
  end
  resources :uploads do
    collection do
      get :batch
      get :image_proxy
    end
  end
  resources :users do
    resource :password, :only => [:edit], :controller => "maintenance/user/passwords"
    resource :api_key, :only => [:show, :view, :update, :destroy], :controller => "maintenance/user/api_keys" do
      post :view
    end

    collection do
      get :search
      get :custom_style
    end

    member do
      delete :cache
    end
  end
  resource :user_upgrade, :only => [:new, :create, :show]
  resources :user_feedbacks do
    collection do
      get :search
    end
  end
  resources :user_name_change_requests do
    member do
      post :approve
      post :reject
    end
  end
  resource :user_revert, :only => [:new, :create]
  resources :wiki_pages do
    member do
      put :revert
    end
    collection do
      get :search
      get :show_or_new
    end
  end
  resources :wiki_page_versions, :only => [:index, :show, :diff] do
    collection do
      get :diff
    end
  end

  # aliases
  resources :wpages, :controller => "wiki_pages"
  resources :ftopics, :controller => "forum_topics"
  resources :fposts, :controller => "forum_posts"
  get "/m/posts", :controller => "mobile/posts", :action => "index"
  get "/m/posts/:id", :controller => "mobile/posts", :action => "show"

  # legacy aliases
  get "/artist" => redirect {|params, req| "/artists?page=#{req.params[:page]}&search[name]=#{CGI::escape(req.params[:name].to_s)}"}
  get "/artist/index.xml", :controller => "legacy", :action => "artists", :format => "xml"
  get "/artist/index.json", :controller => "legacy", :action => "artists", :format => "json"
  get "/artist/index" => redirect {|params, req| "/artists?page=#{req.params[:page]}"}
  get "/artist/show/:id" => redirect("/artists/%{id}")
  get "/artist/show" => redirect {|params, req| "/artists?name=#{CGI::escape(req.params[:name].to_s)}"}
  get "/artist/history/:id" => redirect("/artist_versions?search[artist_id]=%{id}")
  get "/artist/recent_changes" => redirect("/artist_versions")

  get "/comment" => redirect {|params, req| "/comments?page=#{req.params[:page]}"}
  get "/comment/index" => redirect {|params, req| "/comments?page=#{req.params[:page]}"}
  get "/comment/show/:id" => redirect("/comments/%{id}")
  get "/comment/new" => redirect("/comments")
  get("/comment/search" => redirect do |params, req|
    if req.params[:query] =~ /^user:(.+)/i
      "/comments?group_by=comment&search[creator_name]=#{CGI::escape($1)}"
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

  get "/help/:title" => redirect {|params, req| ("/wiki_pages?title=#{CGI::escape('help:' + req.params[:title])}")}

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
  get "/post/create.xml", :controller => "legacy", :action => "create_post", :format => "xml"
  get "/post/piclens", :controller => "legacy", :action => "unavailable"
  get "/post/index" => redirect {|params, req| "/posts?tags=#{CGI::escape(req.params[:tags].to_s)}&page=#{req.params[:page]}"}
  get "/post" => redirect {|params, req| "/posts?tags=#{CGI::escape(req.params[:tags].to_s)}&page=#{req.params[:page]}"}
  get "/post/upload" => redirect("/uploads/new")
  get "/post/moderate" => redirect("/moderator/post/queue")
  get "/post/atom" => redirect {|params, req| "/posts.atom?tags=#{CGI::escape(req.params[:tags].to_s)}"}
  get "/post/atom.feed" => redirect {|params, req| "/posts.atom?tags=#{CGI::escape(req.params[:tags].to_s)}"}
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
  get "/tag" => redirect {|params, req| "/tags?page=#{req.params[:page]}&search[name_matches]=#{CGI::escape(req.params[:name].to_s)}&search[order]=#{req.params[:order]}&search[category]=#{req.params[:type]}"}
  get "/tag/index" => redirect {|params, req| "/tags?page=#{req.params[:page]}&search[name_matches]=#{CGI::escape(req.params[:name].to_s)}&search[order]=#{req.params[:order]}"}

  get "/tag_implication" => redirect {|params, req| "/tag_implications?search[name_matches]=#{CGI::escape(req.params[:query].to_s)}"}

  get "/user/index.xml", :controller => "legacy", :action => "users", :format => "xml"
  get "/user/index.json", :controller => "legacy", :action => "users", :format => "json"
  get "/user" => redirect {|params, req| "/users?page=#{req.params[:page]}"}
  get "/user/index" => redirect {|params, req| "/users?page=#{req.params[:page]}"}
  get "/user/show/:id" => redirect("/users/%{id}")
  get "/user/login" => redirect("/sessions/new")
  get "/user_record" => redirect {|params, req| "/user_feedbacks?search[user_id]=#{req.params[:user_id]}"}

  get "/wiki" => redirect {|params, req| "/wiki_pages?page=#{req.params[:page]}"}
  get "/wiki/index" => redirect {|params, req| "/wiki_pages?page=#{req.params[:page]}"}
  get "/wiki/rename" => redirect("/wiki_pages")
  get "/wiki/show" => redirect {|params, req| "/wiki_pages?title=#{CGI::escape(req.params[:title].to_s)}"}
  get "/wiki/recent_changes" => redirect {|params, req| "/wiki_page_versions?search[updater_id]=#{req.params[:user_id]}"}
  get "/wiki/history/:title" => redirect("/wiki_page_versions?title=%{title}")

  get "/static/keyboard_shortcuts" => "static#keyboard_shortcuts", :as => "keyboard_shortcuts"
  get "/static/bookmarklet" => "static#bookmarklet", :as => "bookmarklet"
  get "/static/site_map" => "static#site_map", :as => "site_map"
  get "/static/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  post "/static/accept_terms_of_service" => "static#accept_terms_of_service", :as => "accept_terms_of_service"
  get "/static/mrtg" => "static#mrtg", :as => "mrtg"
  get "/static/contact" => "static#contact", :as => "contact"
  get "/static/benchmark" => "static#benchmark"
  get "/static/name_change" => "static#name_change", :as => "name_change"
  get "/meta_searches/tags" => "meta_searches#tags", :as => "meta_searches_tags"

  get "/intro" => redirect("/explore/posts/intro")

  root :to => "posts#index"

  get "*other", :to => "static#not_found"
end
