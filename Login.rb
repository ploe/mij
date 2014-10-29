#! /usr/bin/ruby

class Login

def Login.render(params)
	email = CGI.unescape(params[:email])
	key = CGI.unescape(params[:key])

	prompt = "Login: User \"#{email}\" could not be logged in."
	
	user = nil
	if User.exists?(email) then 
		user = User.new(email, key)
	end

	meta = ""
	if (user) and (user.newkey == key) and not user.perks['banned'] then
		user.login
		prompt = "<IMG src=\"throbber.gif\"> Success! You're now logged in... Champ."
		if user.pseudonym == "" then meta = meta_refresh(4, "/page?src=register")
		else meta = meta_refresh(4, "/zine") end
	else
		prompt = "Login: Failed..."
	end

	tatl = Tatl.render(user)

	madlib File.read("/mij/src/res/bare.html"), {
		'content' => "<DIV class=\"content\">#{prompt}</DIV><BR>",
		'domain' => params[:domain],
		'meta' => meta,
		'tatl' => tatl,
		'title' => "logging in",
	}
end


end
