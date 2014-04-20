#! /usr/bin/ruby

require 'sinatra'
set :bind, '0.0.0.0'
set :port, 8989
set :environment, :production

require 'json'
require './mij.rb'

get '/login' do
	response.set_cookie 'session',  {
		:value => {:key => "1234", :email => "ploe@ploe.co.uk"},
		:max_age => "2592000",
	}
end

get '/cookie' do
	request.cookies['session'];
end

get '/' do
	BoardIndex.new.render(nil)	
end

get '/email' do
	Email.render("hello, <!-- {to} -->", {'to' => "ploe@hotmail.co.uk", 'subject' => 'Test email champ' })
end

get '/break' do
	string = "" + nil
end

# A topic is an individual thread on a board. A topic is essentially a 
# nest of posts in a directory
get '/topic' do
	res, err = Topic.new.render(params)
end

post '/post' do
	Post.new.render(params[:article])
end

post '/preview' do
	Preview.new.render(params[:article])
end

post '/keygen' do
	Keygen.new.render(params)
end

