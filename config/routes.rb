Danbooru::Application.routes.draw do
  namespace :admin do
    resources :users, :only => [:edit, :update]
    resource  :alias_and_implication_import, :only => [:new, :create]
  end
  namespace :moderator do
    resource :dashboard, :only => [:show]
    resources :ip_addrs, :only => [:index] do
      collection do
        get :search
      end
    end
    resources :invitations, :only => [:new, :create, :index]
    resource :tag, :only => [:edit, :update]
    namespace :post do
      resource :queue, :only => [:show]
      resource :approval, :only => [:create]
      resource :disapproval, :only => [:create]
      resources :posts, :only => [:delete, :undelete, :expunge, :confirm_delete] do
        member do
          get :confirm_delete
          post :expunge
          post :delete
          post :undelete
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
    resources :posts, :only => [:popular, :hot] do
      collection do
        get :popular
        get :hot
      end
    end
  end
  namespace :maintenance do
    namespace :user do
      resource :password_reset, :only => [:new, :create, :edit, :update]
      resource :login_reminder, :only => [:new, :create]
    end
  end

  resources :advertisements do
    resources :hits, :controller => "advertisement_hits", :only => [:create]
  end
  resources :artists do
    member do
      put :revert
      put :ban
    end
    collection do
      get :show_or_new
      get :search
      get :banned
    end
  end
  resources :artist_versions, :only => [:index]
  resources :bans
  resources :comments do
    resources :votes, :controller => "comment_votes", :only => [:create, :destroy]
    collection do
      get :search
      get :index_all
    end
  end
  resources :delayed_jobs, :only => [:index]
  resources :dmails do
    collection do
      get :search
      post :mark_all_as_read
    end
  end
  resource  :dtext_preview, :only => [:create]
  resources :favorites
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
    end
    collection do
      post :mark_all_as_read
    end
  end
  resources :ip_bans
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
  resource :landing
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
  resources :pools do
    collection do
      get :search
    end
    member do
      put :revert
      post :undelete
    end
    resource :order, :only => [:edit, :update], :controller => "PoolOrders"
  end
  resource  :pool_element, :only => [:create, :destroy] do
    collection do
      get :all_select
    end
  end
  resources :pool_versions, :only => [:index]
  resources :posts do
    resources :votes, :controller => "post_votes", :only => [:create, :destroy]
    member do
      put :revert
      get :show_seq
    end
  end
  resources :post_appeals, :only => [:new, :index, :create]
  resources :post_flags, :only => [:new, :index, :create]
  resources :post_versions, :only => [:index, :search] do
    collection do
      get :search
    end
  end
  resource :related_tag, :only => [:show]
  resource :session do
    collection do
      get :sign_out
    end
  end
  resource :source, :only => [:show]
  resources :tags do
    resource :correction, :only => [:new, :create, :show], :controller => "TagCorrections"
    collection do
      get :search
    end
  end
  resources :tag_aliases do
    resource :correction, :only => [:create, :new, :show], :controller => "TagAliasCorrections"
    member do
      post :approve
    end
    collection do
      get :general_search
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
      get :posts
    end
  end
  resources :uploads
  resources :users do
    collection do
      get :upgrade_information
      get :search
    end

    member do
      delete :cache
      post :upgrade
    end
  end
  resources :user_feedbacks
  resources :user_name_change_requests do
    member do
      post :approve
      post :reject
    end
  end
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

  # legacy aliases
  match "/artist" => redirect {|params, req| "/artists?page=#{req.params[:page]}&search[name]=#{CGI::escape(req.params[:name].to_s)}"}
  match "/artist/index.xml", :controller => "legacy", :action => "artists", :format => "xml"
  match "/artist/index.json", :controller => "legacy", :action => "artists", :format => "json"
  match "/artist/index" => redirect {|params, req| "/artists?page=#{req.params[:page]}"}
  match "/artist/show/:id" => redirect("/artists/%{id}")
  match "/artist/show" => redirect {|params, req| "/artists?name=#{CGI::escape(req.params[:name].to_s)}"}
  match "/artist/history/:id" => redirect("/artist_versions?search[artist_id]=%{id}")
  match "/artist/update/:id" => redirect("/artists/%{id}")
  match "/artist/destroy/:id" => redirect("/artists/%{id}")
  match "/artist/recent_changes" => redirect("/artist_versions")
  match "/artist/create" => redirect("/artists")

  match "/comment" => redirect {|params, req| "/comments?page=#{req.params[:page]}"}
  match "/comment/index" => redirect {|params, req| "/comments?page=#{req.params[:page]}"}
  match "/comment/show/:id" => redirect("/comments/%{id}")
  match "/comment/new" => redirect("/comments")
  match "/comment/search" => redirect("/comments/search")

  match "/favorite" => redirect {|params, req| "/favorites?page=#{req.params[:page]}"}
  match "/favorite/index" => redirect {|params, req| "/favorites?page=#{req.params[:page]}"}
  match "/favorite/list_users.json", :controller => "legacy", :action => "unavailable"

  match "/forum" => redirect {|params, req| "/forum_topics?page=#{req.params[:page]}"}
  match "/forum/index" => redirect {|params, req| "/forum_topics?page=#{req.params[:page]}"}
  match "/forum/show/:id" => redirect("/forum_posts/%{id}")
  match "/forum/search" => redirect("/forum_posts/search")
  match "/forum/new" => redirect("/forum_posts/new")
  match "/forum/edit/:id" => redirect("/forum_posts/%{id}/edit")

  match "/help/:title" => redirect {|params, req| ("/wiki_pages?title=#{CGI::escape('help:' + req.params[:title])}")}

  match "/note" => redirect {|params, req| "/notes?page=#{req.params[:page]}"}
  match "/note/index" => redirect {|params, req| "/notes?page=#{req.params[:page]}"}
  match "/note/history" => redirect("/note_versions")

  match "/pool" => redirect {|params, req| "/pools?page=#{req.params[:page]}"}
  match "/pool/index" => redirect {|params, req| "/pools?page=#{req.params[:page]}"}
  match "/pool/show/:id" => redirect("/pools/%{id}")
  match "/pool/history/:id" => redirect("/pool_versions?search[pool_id]=%{id}")
  match "/pool/recent_changes" => redirect("/pool_versions")

  match "/post/index.xml", :controller => "legacy", :action => "posts", :format => "xml"
  match "/post/index.json", :controller => "legacy", :action => "posts", :format => "json"
  match "/post/create.xml", :controller => "legacy", :action => "create_post", :format => "xml"
  match "/post/piclens", :controller => "legacy", :action => "unavailable"
  match "/post/index" => redirect {|params, req| "/posts?tags=#{CGI::escape(req.params[:tags].to_s)}&page=#{req.params[:page]}"}
  match "/post" => redirect {|params, req| "/posts?tags=#{CGI::escape(req.params[:tags].to_s)}&page=#{req.params[:page]}"}
  match "/post/upload" => redirect("/uploads/new")
  match "/post/moderate" => redirect("/moderator/post/queue")
  match "/post/atom" => redirect {|params, req| "/posts.atom?tags=#{CGI::escape(req.params[:tags].to_s)}"}
  match "/post/atom.feed" => redirect {|params, req| "/posts.atom?tags=#{CGI::escape(req.params[:tags].to_s)}"}
  match "/post/popular_by_day" => redirect("/explore/posts/popular")
  match "/post/popular_by_week" => redirect("/explore/posts/popular")
  match "/post/popular_by_month" => redirect("/explore/posts/popular")
  match "/post/show/:id/:tag_title" => redirect("/posts/%{id}")
  match "/post/show/:id" => redirect("/posts/%{id}")
  match "/post/view/:id/:tag_title" => redirect("/posts/%{id}")
  match "/post/view/:id" => redirect("/posts/%{id}")
  match "/post/flag/:id" => redirect("/posts/%{id}")

  match "/post_tag_history" => redirect {|params, req| "/post_versions?page=#{req.params[:page]}"}
  match "/post_tag_history/index" => redirect {|params, req| "/post_versions?page=#{req.params[:page]}"}

  match "/tag/index.xml", :controller => "legacy", :action => "tags", :format => "xml"
  match "/tag/index.json", :controller => "legacy", :action => "tags", :format => "json"
  match "/tag" => redirect {|params, req| "/tags?page=#{req.params[:page]}&search[name_matches]=#{CGI::escape(req.params[:name].to_s)}&search[order]=#{req.params[:order]}&search[category]=#{req.params[:type]}"}
  match "/tag/index" => redirect {|params, req| "/tags?page=#{req.params[:page]}&search[name_matches]=#{CGI::escape(req.params[:name].to_s)}&search[order]=#{req.params[:order]}"}

  match "/tag_implication" => redirect {|params, req| "/tag_implications?search[name_matches]=#{CGI::escape(req.params[:query].to_s)}"}

  match "/user/index.xml", :controller => "legacy", :action => "users", :format => "xml"
  match "/user/index.json", :controller => "legacy", :action => "users", :format => "json"
  match "/user" => redirect {|params, req| "/users?page=#{req.params[:page]}"}
  match "/user/index" => redirect {|params, req| "/users?page=#{req.params[:page]}"}
  match "/user/show/:id" => redirect("/users/%{id}")
  match "/user/login" => redirect("/sessions/new")

  match "/wiki" => redirect {|params, req| "/wiki_pages?page=#{req.params[:page]}"}
  match "/wiki/index" => redirect {|params, req| "/wiki_pages?page=#{req.params[:page]}"}
  match "/wiki/revert" => redirect("/wiki_pages")
  match "/wiki/rename" => redirect("/wiki_pages")
  match "/wiki/show" => redirect {|params, req| "/wiki_pages?title=#{CGI::escape(req.params[:title].to_s)}"}
  match "/wiki/recent_changes" => redirect("/wiki_page_versions")
  match "/wiki/history/:title" => redirect("/wiki_page_versions?title=%{title}")

  match "/static/keyboard_shortcuts" => "static#keyboard_shortcuts", :as => "keyboard_shortcuts"
  match "/static/bookmarklet" => "static#bookmarklet", :as => "bookmarklet"
  match "/static/site_map" => "static#site_map", :as => "site_map"
  match "/static/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  match "/static/mrtg" => "static#mrtg", :as => "mrtg"
  match "/static/contact" => "static#contact", :as => "contact"
  match "/static/benchmark" => "static#benchmark"
  match "/static/name_change" => "static#name_change", :as => "name_change"

  root :to => "posts#index"
end
