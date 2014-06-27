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

attr_accessor :perks, :email, :key, :pseudonym

def initialize(email, key)
	@email = email
	@key = key

	@pseudonym = ""
	if File.exists?(path + "/pseudonym") then
		@pseudonym = File.read(path + "/pseudonym")		
	end

	@perks = {}
	Dir.foreach(path + "/perks") do |i|
		@perks[i] = true
	end
end

# Builds a new user directory
def path
	"/mij/accounts/" + @email
end

#
def login
	if File.exists?(path + "/newkey") then
		File.rename(path + "/newkey", path + "/key")
	end
end

def logout
	File.open(path + '/key', "w").close
end

def authentic
        if File.read(path + "/key") == @key then return true end
        false
end

def newkey
	if File.exists?(path + "/newkey")
		return File.read(path + "/newkey")
        end
	""
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
	File.open(post + "/#{@pseudonym}", "w") do |file|
		file.write(body)
	end

	"Success! \"#{title}\" was uploaded."
end

def set_pseudonym(str)
	if str !~ /^[[:alnum:]_ ]+$/ then 
		return "User: Pseudonym \"#{str}\" disallowed since it should only contain alpha-numeric characters, underscores and spaces ([A-Za-z0-9_ ])"
	end

	if (len = str.length) > 42 then
		return "User: Hey, your pseudonym can only be 42 characters and \"#{str}\" is #{len}. Arbitrary."
	end

	if @pseudonym != "" then
		return "User: Silly... You can't set your username to \"#{str}\" as it's already \"#{@pseudonym}\""
	end

	dst =  "/mij/pseudonym/#{str}"
	if File.exists?(dst) then
		return "User: Gosh, I'm sorry. A user with the pseudonym \"#{str}\" already exists! Whoops..."
	end

	FileUtils.symlink(path, dst)
	FileUtils.symlink(path + "/posts", "/mij/submissions/" + str)	
	FileUtils.symlink(path + "/featured", "/mij/featured/" + str)	

	File.open(path + "/pseudonym", "w") do |file|
		file.write(str)
	end


	return "Success!"
end

def User.exists?(email)
	Dir.exists?("/mij/accounts/" + email)
end

def User.register(email)
	path = "/mij/accounts/" + email

	home = Dir.mkdir(path)
	File.open(path + "/key", "w").close
        Dir.mkdir(path + "/posts")
        Dir.mkdir(path + "/perks")
        Dir.mkdir(path + "/featured")

end

def User.fetch_article(user, article)
	path = "/mij/pseudonym/#{user}/posts/#{article}/#{user}" 
	if File.exists?(path) then return File.read(path) end
	""
end

def User.count_buzz(user, article)
	path = "/mij/submissions/#{user}/#{article}"
	count = -1
	Dir.foreach(path) do |file|
		if file =~ /^\./ then next end
		count += 1
	end

	count
end

end
