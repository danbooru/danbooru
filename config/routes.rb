Danbooru::Application.routes.draw do
  namespace :admin do
    resources :users, :only => [:get, :put, :destroy]
  end
  namespace :moderator do
    resource :dashboard, :only => [:show]
    resources :ip_addrs, :only => [:index] do
      collection do
        get :search
      end
    end
    resource :tag
    namespace :post do
      resource :dashboard, :only => [:show]
      resource :approval, :only => [:create]
      resource :disapproval, :only => [:create]
      resources :posts, :only => [:delete, :undelete] do
        member do
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
  resources :advertisements do
    resources :hits, :controller => "advertisement_hits", :only => [:create]
  end
  resources :artists do
    member do
      put :revert
    end
    collection do
      get :search
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
  resources :dmails
  resource  :dtext_preview, :only => [:create]
  resources :favorites
  resources :forum_topics
  resources :forum_posts do
    collection do
      get :search
    end
  end
  resources :janitor_trials do
    member do
      put :promote
      put :demote
    end
  end
  resources :jobs
  resources :ip_bans
  resources :mod_actions
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

  resources :post_versions, :only => [:index]
  resources :post_flags, :only => [:new, :index, :create]
  resources :post_appeals, :only => [:new, :index, :create]
  resource  :session
  resources :tags do
    collection do
      get :search
    end
  end
  resources :tag_aliases do
    member do
      delete :cache
    end
  end
  resources :tag_implications
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
  end
  resources :wiki_page_versions, :only => [:index, :show]

  namespace :explore do
    namespace :post do
      resource :popular, :only => [:show]
      resource :hot, :only => [:show]
    end
  end

  namespace :maintenance do
    namespace :user do
      resource :password_reset, :only => [:new, :create, :edit, :update]
      resource :login_reminder, :only => [:new, :create]
    end
  end

  match "/site_map" => "static#site_map", :as => "site_map"
  match "/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  
  root :to => "posts#index"
end
