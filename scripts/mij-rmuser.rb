#! /usr/bin/ruby

require 'fileutils'

if ARGV.length == 0 then
	$stderr.puts( 
		"mij rmuser [LIST OF PSEUDONYMS AND/OR EMAIL ADDRESSES]",
		"Give rmuser a bunch of pseudonyms and email addresses and it will strip them out of mij.",
	)
	exit -1
end

ARGV.each do |user|
	pseudonym = "/mij/pseudonym/" + user
	featured = "/mij/featured/" + user
	submissions = "/mij/submissions/" + user
	account = "/mij/accounts/" + user

	if File.exists?(pseudonym) then
		account = File.readlink(pseudonym)
		FileUtils.rm_rf(pseudonym)
		FileUtils.rm_rf(featured)
		FileUtils.rm_rf(submissions)
		FileUtils.rm_rf(account)
	elsif File.exists?(account)
		FileUtils.rm_rf(account)	
	else
		$stderr.puts "mij rmuser: \"#{user}\" does not exist in any way shape or form on this system. Soz!"
	end
end
