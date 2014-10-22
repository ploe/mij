#! /usr/bin/ruby

require 'fileutils'

timeout = 7*86400

Dir.foreach("/mij/pseudonym") do |user|
	if (user == "..") or (user == ".") then next end
	
	Dir.foreach("/mij/pseudonym/#{user}/posts/") do |post|
		if (post == "..") or (post == ".") then next end
		path = "/mij/pseudonym/#{user}/posts/#{post}"

		now = Time.new.to_i
		if now > File.mtime(path).to_i + timeout then
			#puts "remove #{user}'s '#{post}'"
			FileUtils.rm_rf(path)
		end
	end
end
