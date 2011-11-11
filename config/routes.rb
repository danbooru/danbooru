Danbooru::Application.routes.draw do
  namespace :admin do
    resources :users, :only => [:edit, :update]
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
  resources :dmails do
    collection do
      get :search
    end
  end
  resource  :dtext_preview, :only => [:create]
  resources :favorites
  resources :forum_posts do
    collection do
      get :search
    end
  end
  resources :forum_topics
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
  resources :users
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

  namespace :m do
    resources :posts
    resource :session
  end

  # aliases
  resources :wpages, :controller => "wiki_pages"
  resources :ftopics, :controller => "forum_topics"
  resources :fposts, :controller => "forum_posts"

  # legacy aliases
  match "/artist" => "artists#index"
  match "/artist/index" => "artists#index"
  match "/artist/show/:id" => "artists#show"
  match "/artist/history/:id" => "artist_versions#index"
  
  match "/comment" => "comments#index"
  match "/comment/index" => "comments#index"
  match "/comment/show/:id" => "comments#show"
  
  match "/favorite" => "favorites#index"
  match "/favorite/index" => "favorites#index"
  
  match "/forum" => "forum_topics#index"
  match "/forum/index" => "forum_topics#index"
  match "/forum/show/:id" => "forum_posts#show"

  match "/note" => "notes#index"
  match "/note/index" => "notes#index"
  match "/note/history" => "note_versions#index"
  
  match "/pool" => "pools#index"
  match "/pool/index" => "pools#index"
  match "/pool/show/:id" => "pools#show"
  match "/pool/history/:id" => "pool_versions#index"
  match "/pool/recent_changes" => "pool_versions#index"
  
  match "/post/index" => "posts#index"
  match "/post" => "posts#index"
  match "/post/upload" => "uploads#new"
  match "/post/moderate" => "moderator/post/queues#show"
  match "/post/atom" => "posts#index.atom"
  match "/post/atom.feed" => "posts#index.atom"
  match "/post/popular_by_day" => "explore/posts#popular"
  match "/post/popular_by_week" => "explore/posts#popular"
  match "/post/popular_by_month" => "explore/posts#popular"
  match "/post/show/:id/:tag_title" => "posts#show"
  match "/post/show/:id" => "posts#show"
  
  match "/post_tag_history" => "post_versions#index"
  match "/post_tag_history/index" => "post_versions#index"
  
  match "/tag" => "tags#index"
  match "/tag/index" => "tags#index"
  
  match "/user" => "users#index"
  match "/user/index" => "users#index"
  
  match "/wiki" => "wiki_pages#index"
  match "/wiki/index" => "wiki_pages#index"
  match "/wiki/show/:title" => "wiki_pages#index"
  match "/wiki/recent_changes" => "wiki_page_versions#index"
  match "/wiki/history/:title" => "wiki_page_versions#index"

  match "/static/keyboard_shortcuts" => "static#keyboard_shortcuts", :as => "keyboard_shortcuts"
  match "/static/bookmarklet" => "static#bookmarklet", :as => "bookmarklet"
  match "/static/site_map" => "static#site_map", :as => "site_map"
  match "/static/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  
  root :to => "posts#index"
end
