#! /usr/bin/ruby

# User is the type we use to represent a client and their perks in mij.
#
# The pseudonym is stored as CGI escaped, this means we can have all kinds
# of meta characters floating around in it and we just don't care.
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
		@pseudonym = CGI.unescape(File.read(path + "/pseudonym"))
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
	post = path + "/posts/" + CGI.escape(title)
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
		file.write(CGI.escapeHTML(body))
	end

	"Success! \"#{title}\" was uploaded."
end

def critique(user, title, body)
	article = User.fetch_article(user, title, false)
	path = article['path'] + CGI.escape(@pseudonym)

	# Some strings return 'Success!' - even though not technically being successful so the calling process can render a meta_refresh
	if not article['exists?'] then
		$stderr.puts "Does not exist: " + article['path']
		return "User: Say buddy, the article \"#{article['html-title']}\" by \"#{article['html-user']}\" which you're trying to critique does not exist. Weird...!"
	elsif @pseudonym == user then
		return "User: Dude, \"#{article['html-title']}\" is your own article. You know what they say about self praise, right? (Proverbs 27:2)<!-- Success! -->"
	elsif File.exists?(path) then
		return "User: You've already critiqued the article  \"#{article['html-title']}\" by \"#{article['html-user']}\". Pipe down!<!-- Success! -->"
	elsif body == "" then
		return "User: Hey! Your body is missing."
	elsif body.length > 1000000 then
		return "User: Critique exceeds a million characters. Edit?" 
	end

	File.open(path, "w") do |file|
		file.write(CGI.escapeHTML(body))
	end

	"Success! Criticism submitted on \"#{article['html-title']}\" by \"#{article['html-user']}\" - Gratz!"
end

def set_pseudonym(str)
	if (len = str.length) > 42 then
		return "User: Hey, your pseudonym can only be 42 characters and \"#{str}\" is #{len}. Arbitrary."
	end

	if @pseudonym != "" then
		return "User: Silly... You can't set your username to \"#{str}\" as it's already \"#{@pseudonym}\""
	end

	str = CGI.escape(str)
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

#	builds up an article hash, last param turns off trying to eat the 
#	content.
def User.fetch_article(user, article, getcontent=true)
	article = {
		'title' => article,
		'cgi-title' => CGI.escape(article),
		'html-title' => CGI.escapeHTML(article),
		
		'user' => user,
		'cgi-user' => CGI.escape(user),
		'html-user' => CGI.escapeHTML(user),
	}

	article['path'] = "/mij/pseudonym/#{article['cgi-user']}/posts/#{article['cgi-title']}/"
	article['exists?'] = File.exists?(article['path'])

	if getcontent and article['exists?'] then
		article['added'] = File.mtime(article['path']).to_i

		path = article['path'] + article['cgi-user']
		article['body'] = GitHub::Markdown.render_gfm(File.read(path))
		article['updated'] = File.mtime(path).to_i
		article['critiques'] = fetch_critiques(article)
	end

	article
end

def User.fetch_critiques(article)
	critiques = []
	Dir.foreach(article['path']) do |file|
		if file == article['cgi-user'] or file == ".." or file == "." then
			next
		end

		fullpath = article['path'] + file 
		critiques.push ({
			'user' => file,
			'critique' => GitHub::Markdown.render_gfm(File.read(fullpath)),
			'added' => File.mtime(fullpath).to_i,
		})
	end

	critiques.sort_by! do |c|
		c['added']
	end

	critiques	
end

def User.count_buzz(user, article)
	article = CGI.escape(article)
	user = CGI.escape(user)

	path = "/mij/submissions/#{user}/#{article}"
	count = -1
	Dir.foreach(path) do |file|
		if file =~ /^\./ then next end
		count += 1
	end

	count
end

end
