require 'sinatra'
require 'redis'

redis = Redis.new

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def random_string(length)
    rand(36**length).to_s(36)
  end
end

get '/' do
  erb :index
end

get '/list' do
	@urls = redis.get "links:*"
	erb :list
end

post '/' do
  if params[:url] and not params[:url].empty?
    @shortcode = random_string 5
    redis.setnx "links:#{@shortcode}", params[:url]
  end
  erb :index
end

get '/:shortcode' do
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || '/'
end

