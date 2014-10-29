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

require 'cgi'
require 'github/markdown'

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
	elsif User.fetch_article(@pseudonym, CGI.escape(title))['exists?'] then
		return "User: Submission named \"#{title}\" already exists. Damnit!"
	elsif body == "" then
		return "User: No text in your submission. Well...!"
	elsif body.length > 1000000 then 
		return "User: Submission exceeds a million characters. OHMY."
	elsif User.count_submissions(@pseudonym) >= 5 then
		return "User: You've already submitted five times. Wait for your work to be featured - or delete some. Your call..."
	end

	Dir.mkdir(post)
	File.open(post + "/#{CGI.escape(@pseudonym)}", "w") do |file|
		file.write(CGI.escapeHTML(body))
	end

	"Success! \"#{title}\" was uploaded."
end

def critique(user, title, body)
	article = User.fetch_article(user, title, false)
	path = article['path'] + CGI.escape(@pseudonym)

	# Some strings return 'Success!' - even though not technically being successful so the calling process can render a meta_refresh
	if not article['exists?'] then
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

def delete_article(title)
	article = User.fetch_article(@pseudonym, title, false)

	if not article['exists?'] then
		return "User: Mate, '#{article['html-title']}' doesn't exist. That's odd."
	end
	
	FileUtils.rm_rf(article["path"])
	return "Success! I've gone and removed '#{article['html-title']}' for you. You can thank me later!"
end

def set_pseudonym(str)
	pseudonym = {
		'html' => CGI.escapeHTML(str),
		'cgi' => CGI.escape(str),
	}

	if (len = str.length) > 42 then
		return "User: Hey, your pseudonym can only be 42 characters and \"#{pseudonym['html']}\" is #{len}. Arbitrary."
	end

	if @pseudonym != "" then
		return "User: Silly... You can't set your username to \"#{pseudonym['html']}\" as it's already \"#{@pseudonym}\""
	end

	dst =  "/mij/pseudonym/#{pseudonym['cgi']}"
	if File.exists?(dst) then
		return "User: Gosh, I'm sorry. A user with the pseudonym \"#{pseudonym['html']}\" already exists! Whoops..."
	end

	FileUtils.symlink(path, dst)
	FileUtils.symlink(path + "/posts", "/mij/submissions/" + pseudonym['cgi'])	
	FileUtils.symlink(path + "/featured", "/mij/featured/" + pseudonym['cgi'])	

	File.open(path + "/pseudonym", "w") do |file|
		file.write(pseudonym['cgi'])
	end


	return "Success! You shall now be know as \"#{pseudonym['html']}\""
end

def User.exists?(email)
	Dir.exists?("/mij/accounts/" + email)
end

def User.register(email)
	path = "/mij/accounts/" + email

	home = Dir.mkdir(path)

	File.open(path + "/email", "w") do |file|
		file.write(email)
	end

	File.open(path + "/key", "w").close
        Dir.mkdir(path + "/posts")
        Dir.mkdir(path + "/perks")
        Dir.mkdir(path + "/featured")

end

def User.feature(user, article)
	user = CGI.escape(user)
	article = CGI.escape(article)

	FileUtils.mv(
		"/mij/pseudonym/#{user}/posts/#{article}", 
		"/mij/pseudonym//#{user}/featured/#{article}"
	)
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

	article['path'], article['exists?'] = User.article_exists?(article['user'], article['title'])

	if article['exists?'] then 
		article = User.fetch_articlestats(article)

		if getcontent then
			path = article['path'] + article['cgi-user']
			article['body'] = GitHub::Markdown.render_gfm(File.read(path))
			article['critiques'] = fetch_critiques(article)
		end
	end

	article
end

def User.fetch_articlestats(article)
	article['added'] = File.mtime(article['path'] + article['cgi-user']).to_i
	article['buzz'] = User.count_buzz(article['user'], article['title'])

	path = article['path'] + article['cgi-user']
	article['updated'] = File.mtime(path).to_i

	article
end

def User.article_exists?(user, article)
	path = "/mij/pseudonym/#{CGI.escape(user)}/posts/#{CGI.escape(article)}/"

	exists = File.exists?(path)

	if not exists then
		path.sub!(/\/posts\//, "\/featured\/")
		exists = File.exists?(path)
	end

	return path, exists
end

def User.fetch_submissions(user)
	path = "/mij/pseudonym/#{CGI.escape(user)}/posts/"
	submissions = []
	Dir.foreach(path) do |file|
		if (file == "..") or (file == ".") then next end
		submissions.push(User.fetch_article(user, CGI.unescape(file), false))
	end

	submissions
end

# just duplicated fetch submissions - you never know when you might want
# to do something special... Nah just lazy, really.
def User.fetch_featured(user)
	path = "/mij/pseudonym/#{CGI.escape(user)}/featured/"
	submissions = []
	Dir.foreach(path) do |file|
		if (file == "..") or (file == ".") then next end
		submissions.push(User.fetch_article(user, CGI.unescape(file), false))
	end

	submissions
end

def User.fetch_critiques(article)
	critiques = []
	Dir.foreach(article['path']) do |file|
		if file == article['cgi-user'] or file == ".." or file == "." then
			next
		end

		fullpath = article['path'] + file 
		critiques.push ({
			'user' => CGI.unescape(file),
			'cgi-user' => file,
			'html-user' => CGI.escapeHTML(CGI.unescape(file)),
			'critique' => GitHub::Markdown.render_gfm(File.read(fullpath)),
			'added' => File.mtime(fullpath).to_i,
			'says' => User.holy_says
		})
	end

	critiques.sort_by! do |c|
		c['added']
	end

	critiques.reverse!
end

def User.holy_says
	[
		"says",
		"shouts",
		"whispers",
		"suggests",
		"opines",
		"orates",
		"soliloquizes",
		"s-s-s-stutters",
		"misspels",
		"reckons",
		"assumes",
		"puts out there",
		"puts forward",
		"moans that",
		"coughs up",
		"spews out",
		"preaches",
		"prays",
		"articulates",
		"argues",
		"distills",
		"demonstrates",
		"dreams that",
		"dishes",
		"doles outs",
		"might've said",
		"types",
		"scribes",
		"writes",
		"draws",
		"summoned",
		"throws out",
		"presents",
		"reveals",
	].sample
end

def User.count_buzz(user, article)
	path, exists = article_exists?(user, article)
	count = -1
	if not exists then return "something's up" end
	Dir.foreach(path) do |file|
		if (file == '.') or (file == '..') then next end
		count += 1
	end

	count
end

def User.count_submissions(user)
	path = "/mij/pseudonym/#{CGI.escape(user)}/posts/"
	count = 0
	Dir.foreach(path) do |file|
		if (file == '.') or (file == '..') then next end
		count += 1
	end

	count

end

def User.count_featured(user)
	path = "/mij/pseudonym/#{CGI.escape(user)}/featured/"
	count = 0
	Dir.foreach(path) do |file|
		if (file == '.') or (file == '..') then next end
		count += 1
	end

	count
end

def User.fetch_email(user)
	path = "/mij/pseudonym/#{CGI.escape(user)}/email"
	if File.exists?(path) then
		return File.read(path)
	end

	return nil
end


end
