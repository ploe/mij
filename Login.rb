#! /usr/bin/ruby

class Login

def Login.render(params)
	dir = "/mij/" + URI.decode(params[:email])
	key = URI.decode(params[:key])
	file = dir + "/newkey"

	newkey = ""
	$stderr.puts File.exists?(newkey)
	if File.exists?(file) then 
		newkey = File.read(file) 
	end

	if key == newkey then
		File.rename(file, dir + "/key")
		return true	
	end

	false
end


end
