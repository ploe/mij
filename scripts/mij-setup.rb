#! /usr/bin/ruby

Dir.mkdir("/mij")
%w(accounts  featured  pseudonym  submissions).each do |file|
	begin
		Dir.mkdir("/mij/" + file)
	rescue SystemCallError
		$stderr.puts "mij-setup: failed to create #{file}, whooops..."
	end
end
