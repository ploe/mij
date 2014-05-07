#! /usr/bin/ruby

require 'sinatra'
set :bind, '0.0.0.0'
set :port, 8989
set :environment, :production

require 'json'
require './mij.rb'
require './User.rb'
require './Tatl.rb'

def get_user(request)
	session = request.cookies['session']
	if session == nil then return nil end
	session = JSON.load(session)
	user = nil
	if User.exists?(session["email"]) then user = User.new(session["email"], session["key"]) end
	user
end

get '/slugger' do
	user = get_user(request)
	Tatl.render(user)	
end

get '/login' do
	if (Login.render(params)) then
		value = JSON.dump({:key => URI.decode(params[:key]), :email => URI.decode(params[:email])})
		response.set_cookie 'session',  {
			:value => value,
			:max_age => "2419200",
		}
	end

	redirect to('/')
end

get '/logout' do
	user = get_user(request)
	if user then user.logout end
	redirect to('/submission')	
end

get '/submission' do
	tatl = Tatl.render(get_user(request))
	File.read("res/bare.html").sub(/<!-- {tatl} -->/, tatl)
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
	Keygen.new.render(params, get_user(request))
end
