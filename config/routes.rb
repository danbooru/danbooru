Danbooru::Application.routes.draw do |map|
  namespace :admin do
    resources :users
  end

  resources :advertisements
  resources :artists do
    member do
      put :revert
    end
  end
  resources :artist_versions
  resources :bans
  resources :comments
  resources :comment_votes
  resources :dmails
  resources :favorites
  resources :forum_posts
  resources :forum_topics
  resources :janitor_trials
  resources :jobs
  resources :notes
  resources :pools do
    member do
      put :revert
    end
  end
  resources :pool_versions
  resources :posts do
    member do
      put :revert
    end
  end
  resources :post_moderation_details
  resources :post_versions
  resources :post_votes
  resources :reports
  resources :sessions
  resources :tags
  resources :tag_aliases
  resources :tag_implications
  resources :tag_subscriptions
  resources :unapprovals
  resources :users
  resources :user_feedback
  resources :wiki_pages do
    member do
      put :revert
    end
  end
  resources :wiki_page_versions

  match "/site_map" => "static#site_map"
  
  root :to => "post#index"
end
