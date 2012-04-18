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
      resources :posts, :only => [:delete, :undelete] do
        member do
          post :annihilate
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
    end
  end
  resources :delayed_jobs, :only => [:index]
  resources :dmails do
    collection do
      get :search
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
  resource  :pool_element, :only => [:create, :destroy]
  resources :pool_versions, :only => [:index]
  resources :posts do
    resources :votes, :controller => "post_votes", :only => [:create, :destroy]
    member do
      put :revert
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
  resource :session
  resource :source, :only => [:show]
  resources :tags do
    collection do
      get :search
    end
  end
  resources :tag_aliases do
    member do
      delete :cache
      post :approve
    end
    collection do
      get :general_search
    end
  end
  resources :tag_implications do
    member do
      post :approve
    end
  end
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
  resources :wiki_pages do
    member do
      put :revert
    end
    collection do
      get :show_or_new
    end
  end
  resources :wiki_page_versions, :only => [:index, :show]
  
  # aliases
  resources :wpages, :controller => "wiki_pages"
  resources :ftopics, :controller => "forum_topics"
  resources :fposts, :controller => "forum_posts"

  # legacy aliases
  match "/artist" => redirect {|params, req| "/artists?page=#{req.params[:page]}"}
  match "/artist/index" => redirect {|params, req| "/artists?page=#{req.params[:page]}"}
  match "/artist/show/:id" => redirect("/artists/%{id}")
  match "/artist/history/:id" => redirect("/artist_versions?search[artist_id]=%{id}")
  
  match "/comment" => redirect {|params, req| "/comments?page=#{req.params[:page]}"}
  match "/comment/index" => redirect {|params, req| "/comments?page=#{req.params[:page]}"}
  match "/comment/show/:id" => redirect("/comments/%{id}")
  
  match "/favorite" => redirect {|params, req| "/favorites?page=#{req.params[:page]}"}
  match "/favorite/index" => redirect {|params, req| "/favorites?page=#{req.params[:page]}"}
  
  match "/forum" => redirect {|params, req| "/forum_topics?page=#{req.params[:page]}"}
  match "/forum/index" => redirect {|params, req| "/forum_topics?page=#{req.params[:page]}"}
  match "/forum/show/:id" => redirect("/forum_posts/%{id}")

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
  match "/post/index" => redirect {|params, req| "/posts?tags=#{req.params[:tags]}&page=#{req.params[:page]}"}
  match "/post" => redirect {|params, req| "/posts?tags=#{req.params[:tags]}&page=#{req.params[:page]}"}
  match "/post/upload" => redirect("/uploads/new")
  match "/post/moderate" => redirect("/moderator/post/queue")
  match "/post/atom" => redirect("/posts.atom")
  match "/post/atom.feed" => redirect("/posts.atom")
  match "/post/popular_by_day" => redirect("/explore/posts/popular")
  match "/post/popular_by_week" => redirect("/explore/posts/popular")
  match "/post/popular_by_month" => redirect("/explore/posts/popular")
  match "/post/show/:id/:tag_title" => redirect("/posts/%{id}")
  match "/post/show/:id" => redirect("/posts/%{id}")
  
  match "/post_tag_history" => redirect {|params, req| "/post_versions?page=#{req.params[:page]}"}
  match "/post_tag_history/index" => redirect {|params, req| "/post_versions?page=#{req.params[:page]}"}
  
  match "/tag" => redirect {|params, req| "/tags?page=#{req.params[:page]}"}
  match "/tag/index" => redirect {|params, req| "/tags?page=#{req.params[:page]}"}
  
  match "/user" => redirect {|params, req| "/users?page=#{req.params[:page]}"}
  match "/user/index" => redirect {|params, req| "/users?page=#{req.params[:page]}"}
  
  match "/wiki" => redirect {|params, req| "/wiki_pages?page=#{req.params[:page]}"}
  match "/wiki/index" => redirect {|params, req| "/wiki_pages?page=#{req.params[:page]}"}
  match "/wiki/show/:title" => redirect("/wiki_pages?title=%{title}")
  match "/wiki/recent_changes" => redirect("/wiki_page_versions")
  match "/wiki/history/:title" => redirect("/wiki_page_versions?title=%{title}")

  match "/static/keyboard_shortcuts" => "static#keyboard_shortcuts", :as => "keyboard_shortcuts"
  match "/static/bookmarklet" => "static#bookmarklet", :as => "bookmarklet"
  match "/static/site_map" => "static#site_map", :as => "site_map"
  match "/static/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  
  root :to => "posts#index"
end
