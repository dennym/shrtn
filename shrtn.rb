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

post '/' do
  if params[:url] and not params[:url].empty?
    @shortcode = random_string 5
    redis.multi do
    	redis.set "links:#{@shortcode}", params[:url], :nx => true, :ex => 20 
  		redis.set "clicks:#{@shortcode}", "0", :nx => true, :ex => 20 
  	end
  end
  erb :index
end

get '/admin' do
	@amount = redis.eval("return #redis.call('keys', 'links:*')")
	erb :admin
end

get '/:shortcode' do
	redis.multi do
  	redis.incr "clicks:#{params[:shortcode]}"
  	@url = redis.get "links:#{params[:shortcode]}"
  end
  redirect @url || '/'
end

