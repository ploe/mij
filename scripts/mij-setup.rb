#! /usr/bin/ruby

if not File.exists?("/mij") then Dir.mkdir("/mij") end%w(accounts  featured  pseudonym  submissions).each do |file|
	begin
		Dir.mkdir("/mij/" + file)
	rescue SystemCallError
		$stderr.puts "mij-setup: failed to create #{file}, whooops..."
	end
end
