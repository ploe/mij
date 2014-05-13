#! /usr/bin/ruby

require 'sinatra'
set :bind, '0.0.0.0'
set :port, 8989
set :environment, :production

require 'json'
require './mij.rb'

# Grabs the user and ensures their cookie is authentic
def get_user(request)
	session = request.cookies['session']
	if session == nil then return nil end
	session = JSON.load(session)
	user = nil
	if User.exists?(session["email"]) then 
		user = User.new(session["email"], session["key"])
		if not user.authentic then user = nil  end
	end

	user
end

get '/page' do
	src = "./public/" + params[:src] + ".html"
	if File.exists?(src) and (content = File.read(src)) then
		tatl = Tatl.render(get_user(request))
		content = madlib(content, {'tatl' => tatl})
	end
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
	article = URI.decode(params[:article])
	user = URI.decode(params[:user])

	path = "/mij/#{user}/posts/#{article}/#{user}" 
	content = File.read(path)

	madlib File.read("res/bare.html"), { 
		'tatl' => Tatl.render(get_user(request)),
		'content' => content,
	}
end

get '/submit' do
	Submit.render(Tatl.render(get_user(request)))
end

get '/' do
	BoardIndex.new.render(nil)	
end

# A topic is an individual thread on a board. A topic is essentially a 
# nest of posts in a directory
get '/topic' do
	res, err = Topic.new.render(params)
end

post '/post' do
	Post.render(params, get_user(request))
end

post '/preview' do
	Preview.new.render(params[:article])
end

post '/keygen' do	
	Keygen.new.render(params, get_user(request))
end
