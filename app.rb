require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'

enable :sessions

helpers do
    def current_content
        Content.find_by(id: session[:content])
    end
end

get '/' do
    erb :index
end

get '/signup' do
    erb :sign_up
end

post '/signup' do
    content = Content.create(
        title: params[:title],
        password: params[:password],
        password_confirmation: params[:password_confirmation]
        )
    if content.persisted?
        session[:content] = content.id   
    end
    redirect '/'
end
