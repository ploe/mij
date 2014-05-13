#! /usr/bin/ruby

# User is the type we use to represent a client and their perks in mij.
#
# posts are the live article submissions they currently have on the system
# These will be blitzed on each iteration.
#
# perks are keys that allow users to access certain features. for instance
# there will be an 'editor' perk that allows the client to feature 
# articles and that, and a 'janitor' perk that allows the user to delete
# spam.
# perks are all loaded in to memory as a set when we identify the user
#
# Their key is the session key that the user is logged in with.
class User

attr_accessor :perks, :email, :key

def initialize(email, key)
	@email = email
	@key = key

	@perks = {}
	Dir.foreach(path + "/perks") do |i|
		@perks[i] = true
	end
end

# Builds a new user directory
def path
	"/mij/" + @email
end

def logout
	File.open(path + '/key', "w").close
end

def authentic
        if File.read(path + "/key") == @key then return true end
        false
end

# Submits a submission, there is a 1 million char limit for reasons.
def post(title, body)
	body.gsub!(/<.*?>/, "")
	post = path + "/posts/" + title
	if title == "" then
		return "User: Huh? You forgot the title for your submission."
	elsif File.exists?(post)
		return "User: Submission named \"#{title}\" already exists. Damnit!"
	elsif body == "" then
		return "User: No text in your submission. Well...!"
	elsif body.length > 1000000 then 
		return "User: Submission exceeds a million characters. OHMY."
	end

	Dir.mkdir(post)
	File.open(post + "/#{@email}", "w") do |file|
		file.write(body)
	end

	"Success! \"#{title}\" was uploaded."
end

def User.exists?(email)
	Dir.exists?("/mij/" + email)
end

def User.register
	path = "/mij/" + email

	home = Dir.mkdir(path)
        Dir.mkdir(path + "/posts")
        Dir.mkdir(path + "/perks")
        Dir.mkdir(path + "/featured")

        user = {
                :pseudonym => "anonymous",
        }

       File.open(path + '/config.json', "w") do |file|
                file.write(JSON.dump(user))
       end
end

end
