require 'sinatra'
require 'json'
require_relative './mock_service_helper'

set :port, 3001

configure do
  POST_IDS = MockServiceHelper.fetch_post_ids
end

get '/recommend/:user_id' do
  content_type :json
  POST_IDS[0..10].map {|x| [x, "1.000"]}.to_json
end

get '/similar/:post_id' do
  content_type :json
  POST_IDS[0..6].map {|x| [x, "1.000"]}.to_json
end
