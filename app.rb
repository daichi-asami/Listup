require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra'
require 'line/bot'
require 'sinatra/activerecord'
require './models'

enable :sessions

helpers do
    def current_content
        Content.find_by(id: session[:content])
    end
end

get '/' do
    if current_content.nil?
      @questions = Question.none
    else
      @questions = current_content.questions
    end
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

get '/signin' do
    erb :sign_in
end

post '/signin' do
    content = Content.find_by(title: params[:title])
    if content && content.authenticate(params[:password])
        session[:content] = content.id
    end
    redirect '/'
end

get '/signout' do
    session[:content] = nil
    redirect '/'
end

get '/questions/new' do
  erb :new
end

post '/questions' do
  current_content.questions.create(title: params[:title])
  redirect '/'
end

def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
      config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
    }
  end
  
  post '/callback' do
    body = request.body.read
  
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
  
    events = client.parse_events_from(body)
    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: event.message['text']
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    }
  
    "OK"
  end
