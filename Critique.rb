#! /usr/bin/ruby

module Critique

def Critique.render(params, tatl)
	user = CGI.unescape(params[:user])
	article = CGI.unescape(params[:article])

	article = User.fetch_article(user, article, false)

	if article['exists?'] then
		madlib File.read("./res/form.html"), {
			'prompt' => "What do you reckon...?",
			'tatl' => tatl,
			'title' => "critique #{article['html-title'].downcase} by #{article['html-user'].downcase}",
			'title-input' =>  "<P>#{article['html-title']} by #{article['html-user']}</P>",
			'verbs' => 
				"<DIV class=\"verbs\">\n" +
				"<BUTTON formmethod=\"post\" id=\"preview\" formaction=\"./critique\">Critique</BUTTON>\n" +
				"</DIV>"
		}
	else
		"bummer..."
	end
end

end
