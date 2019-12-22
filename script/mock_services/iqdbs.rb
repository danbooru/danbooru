require 'sinatra'
require 'json'
require_relative './mock_service_helper'

set :port, 3002

configure do
  POST_IDS = MockServiceHelper.fetch_post_ids
end

get '/similar' do
  content_type :json
  POST_IDS[0..10].map {|x| {post_id: x}}.to_json
end
