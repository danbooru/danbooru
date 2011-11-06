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

  match "/static/keyboard_shortcuts" => "static#keyboard_shortcuts", :as => "keyboard_shortcuts"
  match "/static/bookmarklet" => "static#bookmarklet", :as => "bookmarklet"
  match "/static/site_map" => "static#site_map", :as => "site_map"
  match "/static/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  
  root :to => "landings#show"
end
