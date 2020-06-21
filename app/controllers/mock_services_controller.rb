class MockServicesController < ApplicationController
  skip_forgery_protection
  respond_to :json

  before_action do
    raise User::PrivilegeError if Rails.env.production?
  end

  def recommender_recommend
    @data = posts.map { |post| [post.id, rand(0.0..1.0)] }
    render json: @data
  end

  def recommender_similar
    @data = posts.map { |post| [post.id, rand(0.0..1.0)] }
    render json: @data
  end

  def reportbooru_missed_searches
    @data = tags.map { |tag| "#{tag.name} #{rand(1.0..1000.0)}" }.join("\n")
    render json: @data
  end

  def reportbooru_post_searches
    @data = tags.map { |tag| [tag.name, rand(1..1000)] }
    render json: @data
  end

  def reportbooru_post_views
    @data = posts.map { |post| [post.id, rand(1..1000)] }
    render json: @data
  end

  def iqdbs_similar
    @data = posts.map { |post| { post_id: post.id, score: rand(0..100)} }
    render json: @data
  end

  private

  def posts(limit = 10)
    Post.last(limit)
  end

  def tags(limit = 10)
    Tag.order(post_count: :desc).limit(limit)
  end
end
