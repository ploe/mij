#! /usr/bin/ruby

require 'sinatra'
set :bind, '0.0.0.0'
set :port, 8989
set :environment, :production

require 'json'
require 'cgi'
require 'github/markdown'
require './mij.rb'

$stderr.puts <<LICENSE

Copyright (c) 2014, Myke Atkinson
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer. 
2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

LICENSE

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

get '/pending' do
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

# Zine class is listed as featured on the front page so I have set up
# routes for both.

get '/zine' do
	Zine.get(params)
end

get '/featured' do
	Zine.get(params)
end

get '/feature' do
	Feature.get(params)
end

get '/profile' do
	Profile.get(params)
end

get '/remove/:table' do |type|
	RemoveArticle.get(params)
end

post '/critique' do
	Critique.post(params)	
end

post '/post' do
	Post.render(params)
end

post '/feature' do
	Feature.post(params)
	redirect to("/zine")	
end

post '/register' do
	params[:client].set_pseudonym(params[:pseudonym])
end

post '/keygen' do	
	Keygen.render(params)
	redirect to("/page?src=about")
end

post '/remove/:table' do
	RemoveArticle.post(params)
end
