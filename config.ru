require 'bundler'
Bundler.require

require './app'
run Sinatra::Application

require './app_main'
run Sinatra::Application