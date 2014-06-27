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
	else
		response.delete_cookie('session')
	end

	user
end

get '/page' do
	src = "./public/" + params[:src] + ".html"
	if File.exists?(src) and (content = File.read(src)) then
		madlib(content, {
			'tatl' => Tatl.render(get_user(request)),
			'title' => params[:src]
		})
	end
end

get '/login' do
	key = URI.decode(params[:key])
	email = URI.decode(params[:email])

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
	user = get_user(request)
	if user then user.logout end
	redirect to('/page?src=about')	
end

get '/submission' do
	article = URI.decode(params[:article])
	user = URI.decode(params[:user])

	meta = ""
	content = User.fetch_article(user, article)
	if content == "" then
		content = "Submission: I'm afraid \"#{article}\" by #{user} doesn't exist. Soz, pal!"
		meta = meta_refresh(3, "/page?src=about")
	end

	status 404
	madlib File.read("res/bare.html"), {
		'content' => "<DIV class=\"content\"><P>#{content}</P></DIV><BR>",
		'meta' => meta,
		'title' => "#{article} by #{user}",
		'tatl' => Tatl.render(get_user(request)),
	}
end

get '/submissions' do
	Submissions.render(params, Tatl.render(get_user(request)))
end

get '/submit' do
	user = get_user(request)
	if user and user.pseudonym != "" then
		Submit.render(Tatl.render(get_user(request)))
	elsif user
		redirect to("/page?src=register")
	else	
		redirect to("/page?src=about")
	end
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

post '/register' do
	user = get_user(request)
	user.set_pseudonym(params[:pseudonym])
end

post '/keygen' do	
	Keygen.new.render(params, get_user(request))
	redirect to("/page?src=about")
end
