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

before do
  @title = "shrtn » url shortener"
end

get '/' do
  erb :index
end

get '/list' do
	@urls = redis.keys('*')
	erb :list
end

post '/' do
  if params[:url] and not params[:url].empty?
    @shortcode = random_string 5
    redis.setnx "links:#{@shortcode}", params[:url]
    redis.setnx "clicks:#{@shortcode}", "0"
  end
  erb :index
end

get '/:shortcode' do
  redis.incr "clicks:#{params[:shortcode]}"
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || '/'
end

