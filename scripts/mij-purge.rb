#! /usr/bin/ruby

require 'fileutils'
require 'cgi'
require '/mij/src/User.rb'

timeout = 7*86400

Dir.foreach("/mij/pseudonym") do |user|
	if (user == "..") or (user == ".") then next end
	posts = User.fetch_submissions(CGI.unescape(user))

	posts.each do |p|
		now = Time.new.to_i
		if now > ((File.mtime(p['added']).to_i) + timeout) then
			puts "mij-purge: removing #{user}'s '#{post}'"

			Rejection.get(p['user'], p['title'], "The article wasn't featured after seven days so it was purged from the site.")
		end
	end
end
