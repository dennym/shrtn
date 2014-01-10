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

get '/admin' do
	@amount = redis.eval("return #redis.call('keys', 'links:*')")
	erb :admin
end

post '/' do
  if params[:url] and not params[:url].empty?
    @shortcode = random_string 5
    redis.set "links:#{@shortcode}", params[:url], :nx => true, :ex => 20 
    redis.setnx "clicks:#{@shortcode}", "0"
  end
  erb :index
end

get '/:shortcode' do
  redis.incr "clicks:#{params[:shortcode]}"
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || '/'
end

