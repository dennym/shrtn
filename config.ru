require 'rubygems'
require 'bundler/setup'
require 'sinatra'

run Sinatra::Application

configure do

  SiteConfig = OpenStruct.new(
          :title => 'shrtn » url shortener',
          :author => 'Denny Mueller',
          :url_base => 'http://localhost:4567/' # the url of your application
        )
end