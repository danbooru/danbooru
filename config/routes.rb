Danbooru::Application.routes.draw do
  namespace :admin do
    match 'users/edit' => 'users#edit', :via => :get
    match 'users' => 'users#update', :via => :put
  end
  resources :advertisements do
    resources :hits, :controller => "advertisement_hits", :only => [:create]
  end
  resources :artists do
    member do
      put :revert
    end
  end
  resources :artist_versions, :only => [:index]
  resources :bans
  resources :comments do
    resources :votes, :controller => "comment_votes", :only => [:create, :destroy]
  end
  resources :dmails
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
  resources :notes do
    member do
      put :revert
    end
  end
  resources :note_versions, :only => [:index]
  resources :pools do
    member do
      put :revert
    end
  end
  resources :pool_versions, :only => [:index]
  resources :posts do
    resources :votes, :controller => "post_votes", :only => [:create, :destroy]
    member do
      put :revert
    end
  end

  resources :post_versions, :only => [:index]
  resource :session
  resources :tags
  resources :tag_aliases do
    member do
      delete :cache
    end
  end
  resources :tag_implications
  resources :tag_subscriptions
  resources :unapprovals
  resources :uploads
  resources :users
  resources :user_feedback
  resources :wiki_pages do
    member do
      put :revert
    end
  end
  resources :wiki_page_versions, :only => [:index, :show]

  match '/favorites/:id' => 'favorites#create', :via => :post, :as => "favorite"
  match '/favorites/:id' => 'favorites#destroy', :via => :delete, :as => "favorite"
  match '/favorites' => 'favorites#index', :via => :get, :as => "favorites"
  match '/pool_post' => 'pools_posts#create', :via => :post, :as => 'pool_post'
  match '/pool_post' => 'pools_posts#destroy', :via => :delete, :as => 'pool_post'
  match '/post_moderation/moderate' => 'post_moderation#moderate'
  match '/post_moderation/disapprove' => 'post_moderation#disapprove', :via => :put
  match '/post_moderation/approve' => 'post_moderation#approve', :via => :put
  match '/post_moderation/delete' => 'post_moderation#delete', :via => :post
  match '/post_moderation/undelete' => 'post_moderation#undelete', :via => :post
  match '/dtext/preview' => 'dtext#preview', :via => :post
  match "/site_map" => "static#site_map", :as => "site_map"
  match "/terms_of_service" => "static#terms_of_service", :as => "terms_of_service"
  match "/user_maintenance/login_reminder" => "user_maintenance#login_reminder", :as => "login_reminder"
  match "/user_maintenance/reset_password" => "user_maintenance#reset_password", :as => "reset_password"
  
  root :to => "posts#index"
end
