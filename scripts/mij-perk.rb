#! /usr/bin/ruby

if ARGV.length <= 1 then
	$stderr.puts( 
		"mij perk [PERK NAME] [LIST OF USER PSEUDONYMS]",
		"This script takes the name of the perk and a list of users, and then issues all the users that perk.",
	)
	exit -1
end

perk = ARGV.shift

ARGV.each do |user|
	path = "/mij/pseudonym/#{user}/perks/"
	if not File.exists?(path) then
		$stderr.puts "mij-perk: #{user} doesn't seem to exist"
		next;
	end

	File.open(path + perk, "w").close
end
