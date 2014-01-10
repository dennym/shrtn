require 'sinatra'
require 'redis'

configure do

	SiteConfig = OpenStruct.new(
					:title => 'shrtn » url shortener',
					:author => 'Denny Mueller',
					:url_base => 'http://localhost:4567/' # the url of your application
				)
end

redis = Redis.new

helpers do
	include Rack::Utils
	alias_method :h, :escape_html

	def random_string(length)
		rand(36**length).to_s(36)
	end

	def get_site_url(short_url)
		SiteConfig.url_base + short_url
		end
end

get '/' do
	erb :index
end

post '/' do
	if params[:url] and not params[:url].empty?
		@shortcode = random_string 5
		redis.multi do
			redis.set "links:#{@shortcode}", params[:url], :nx => true, :ex => 400
			redis.set "clicks:#{@shortcode}", "0", :nx => true, :ex => 400
		end
	end
	erb :index
end

get '/admin' do
	@amount = redis.eval("return #redis.call('keys', 'links:*')")
	erb :admin
end

get '/:shortcode' do
	@url = redis.get "links:#{params[:shortcode]}"
	if !@url.nil?
		redis.incr "clicks:#{params[:shortcode]}"
		redirect @url
	else
		redirect '/'
	end
end
