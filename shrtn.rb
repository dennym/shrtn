require 'sinatra'
require 'redis'
require 'sinatra-flash'

configure do
	SiteConfig = OpenStruct.new(
		:title => 'shrtn » url shortener',
		:author => 'Denny Mueller',
		:url_base => 'http://localhost:4567/', # the url of your application
		:username => 'admin',
		:token => 'maketh1$longandh@rdtoremember',
		:password => 'password'
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

  def admin?
  	request.cookies[SiteConfig.username] == SiteConfig.token
  end

  def protected!
  	redirect '/login' unless admin?
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
			r.set "clicks:#{@shortcode}", "0", :nx => true, :ex => 7200
		end
	end
	erb :index
end

get '/login' do
	erb :login
end

post '/login' do
  if params[:username]==SiteConfig.username&&params[:password]==SiteConfig.password
      response.set_cookie(SiteConfig.username,SiteConfig.token) 
      redirect '/admin'
    else
      "Username or Password incorrect"
    end
end

get '/logout' do
	response.set_cookie(SiteConfig.username, false)
	redirect '/'
end

get '/admin' do
	protected!
	@count = r.eval("return #redis.call('keys', 'links:*')")
	@url_shortcodes = r.keys("links:*")
	@clicks = [] ; @urls = [] ; @timeouts = [] #init arrays
	@url_shortcodes.each do |x|
		x.slice! "links:"
		@urls << r.get("links:#{x}")
		@clicks << r.get("clicks:#{x}")
		@timeouts << r.ttl("links:#{x}")
	end
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
