module Rejection

require '/mij/src/User.rb'
require '/mij/src/Dynamo.rb'
require '/mij/Emailer.rb'

def Rejection.get(user, title, reason="no reason given...")
	to = User.fetch_email(user)
	article = User.fetch_article(user, title)

	if article['exists?'] then 
		FileUtils.rm_rf(article['path'])
	

		Email.render("/mij/src/res/rejection.html", {
			'to' => to,
			'body' => article['body'],
			'subject' => "'#{CGI.escapeHTML(title)}' rejection - ploe.co.uk",
			'reason' => CGI.escapeHTML(reason),
			'critiques' => Rejection.render_critiques(article['critiques']), 
			'editor' => "Ploe",
			'user' => CGI.escapeHTML(user),
		})
	end
end

def Rejection.render_critiques(critiques)
	content = Dynamo.new
	critiques.each do |c|
		content.append("<P><STRONG>#{c['html-user']} #{c['says']}:</STRONG><BR>#{c['critique']}</P>")
	end

	if content.to_s == "" then content.append("<P>nobody said anything...</P>") end
	content.to_s
end

end
