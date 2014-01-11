require 'sinatra'
require 'redis'

configure do
	SiteConfig = OpenStruct.new(
		:title => 'shrtn » url shortener',
		:author => 'Denny Mueller',
		:url_base => 'http://localhost:4567/' # the url of your application
	)
end

r = Redis.new

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
		unless params[:url] =~ /[a-zA-Z]+:\/\/.*/
			params[:url] = "http://#{params[:url]}"
		end
		@shortcode = random_string 5
		r.multi do
			r.set "links:#{@shortcode}", params[:url], :nx => true, :ex => 7200
			r.set "clicks:#{@shortcode}", rand(200), :nx => true, :ex => 7200
		end
	end
	erb :index
end

get '/admin' do
	@amount = r.eval("return #redis.call('keys', 'links:*')")
	@url_shortcodes = r.keys("links:*")
	@clicks = []
	@url_shortcodes.each do |x|
		x.slice! "links:"
		@clicks << r.get("clicks:#{x}")
	end
	puts "after loop"
	puts @clicks
	puts @url_shortcodes
	erb :admin
end

get '/:shortcode' do
	@url = r.get "links:#{params[:shortcode]}"
	if !@url.nil?
		r.incr "clicks:#{params[:shortcode]}"
		redirect @url
	else
		redirect '/'
	end
end
