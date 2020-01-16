require 'sinatra'
require 'json'

set :port, 3003

get '/missed_searches' do
  content_type :text
  return "abcdefg 10.0\nblahblahblah 20.0\n"
end

get '/post_searches/rank' do
  content_type :json
  return [["abc", 100], ["def", 200]].to_json
end

get '/reports/user_similarity' do
  # todo
end

post '/post_views' do
  # todo
end
