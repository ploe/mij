#! /usr/bin/ruby

class Keygen

require 'json'
require 'securerandom'
require 'digest/sha2'

require '../Emailer.rb'

def render(params)
	if (not params[:email]) then return ["Keygen: No email input"] end

	email = {
		'to'  => URI.decode(params[:email]),
		'subject' => "ploe.co.uk - Login Key",

	}
	path = "/mij/" + email['to']
	
	if not File.directory?(path) then home = new_user(path) end

	# Creates new session key	
	sha = Digest::SHA2.new(512) << SecureRandom.uuid << email['to']
	email['url'] = "http://ploe.co.uk/login?email=" + email['to'] + "&key=" +  sha.to_s

	# 
	File.open(path + "/newkey", 'w') { |file|
		file.write(email['url'])	
	}
	
	
	Email.render("./res/keygen_email.html", email)
end

private

def new_user(path)
	home = Dir.mkdir(path)
	Dir.mkdir(path + "/posts")
	Dir.mkdir(path + "/perks")
	
	user = {
		:pseudonym => "anonymous",
	}

	File.open(path + '/config.json', "w") { |file|
		file.write(JSON.dump(user))
	}
end

end

