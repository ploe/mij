#! /usr/bin/ruby

require 'sinatra'
set :bind, '0.0.0.0'
set :port, 8989
set :environment, :production

require 'json'
require 'cgi'
require 'github/markdown'
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
	else
		response.delete_cookie('session')
	end

	user
end

before do
	params[:domain] = request.host_with_port

	params[:favicon] = "dev-favicon.ico"
	if params[:domain] == "ploe.co.uk" then
		params[:favicon].sub!(/dev/, "live")
	end

	params[:client] = get_user(request)
	params[:tatl] = Tatl.render(params[:client])
end

get '/page' do
	src = "./public/" + params[:src] + ".html"
	if File.exists?(src) and (content = File.read(src)) then
		madlib(content, {
			'domain' => params[:domain],
			'favicon' => params[:favicon],
			'tatl' => params[:tatl],
			'title' => params[:src]
		})
	end
end

get '/login' do
	key = CGI.unescape(params[:key])
	email = CGI.unescape(params[:email])

	page = Login.render(params)
	if (page =~ /Success/) then
		value = JSON.dump({:key => key, :email => email})
		response.set_cookie 'session',  {
			:value => value,
			:max_age => "2419200",
		}

	end

	page

end

get '/logout' do
	if params[:client] then params[:client].logout end
	redirect to('/page?src=about')	
end

get '/submissions' do
	Submissions.render(params)
end

get '/submit' do
	if params[:client] and params[:client].pseudonym != "" then
		Submit.render(params)
	elsif params[:client]
		redirect to("/page?src=register")
	else	
		redirect to("/page?src=about")
	end
end

get '/article' do
	Article.render(params)
end

get '/critique' do
	Critique.render(params)
end

get '/' do
	redirect to("/page?src=about")	
end

post '/critique' do
	Critique.post(params)	
end

post '/post' do
	Post.render(params)
end

post '/register' do
	params[:client].set_pseudonym(params[:pseudonym])
end

post '/keygen' do	
	Keygen.render(params)
	redirect to("/page?src=about")
end
