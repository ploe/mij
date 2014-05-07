#! /usr/bin/ruby

class Keygen

require 'json'
require 'securerandom'
require 'digest/sha2'

require '../Emailer.rb'

require './User.rb'

def render(params, user)
	if (not params[:email]) then return ["Keygen: No email input"] end

	email = {
		'to'  => URI.decode(params[:email]),
		'subject' => "ploe.co.uk - Login Key",

	}
	path = "/mij/" + email['to']
	
	if not User.exists?(email['to']) then User.register(email['to']) end

	# Creates new session key	
	sha = Digest::SHA2.new(512) << SecureRandom.uuid << email['to']
	email['url'] = "https://ploe.co.uk/login?email=" + email['to'] + "&key=" +  sha.to_s

	File.open(path + "/newkey", 'w') { |file|
		file.write(sha.to_s)	
	}
	
	Email.render("./res/keygen_email.html", email)
end

end

