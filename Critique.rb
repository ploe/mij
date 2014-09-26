#! /usr/bin/ruby

module Critique

def Critique.render(params)
	user = CGI.unescape(params[:user])
	article = CGI.unescape(params[:article])

	article = User.fetch_article(user, article, false)

	if article['exists?'] then
		madlib File.read("./res/form.html"), {
			'domain' => params[:domain],
			'favicon' => params[:favicon],
			'prompt' => "What do you reckon...?",
			'tatl' => params[:tatl],
			'title' => "critique #{article['html-title'].downcase} by #{article['html-user'].downcase}",
			'title-input' =>  
				"<P>#{article['html-title']} by #{article['html-user']}</P>" +
				"<INPUT type=\"hidden\" name=\"article[title]\" value=\"#{article['cgi-title']}\">" +
				"<INPUT type=\"hidden\" name=\"article[user]\" value=\"#{article['cgi-user']}\">",
			'verbs' => 
				"<DIV class=\"verbs\">\n" +
				"<BUTTON formmethod=\"post\" id=\"critique\" formaction=\"./critique\">critique</BUTTON>\n" +
				"</DIV>"
		}
	else
		"bummer..."
	end
end

def Critique.post(params)
	client = params[:client]
	article = params[:article]

	madlibs = {}
	madlibs['favicon'] = params[:favicon]

	madlibs['meta'] = meta_refresh(4, "/article?user=#{article[:user]}&amp;amp;article=#{article[:title]}")

	if (not client) then
		 madlibs['content'] = "<IMG src=\"throbber.gif\"> Critique: You're not allowed to post."
	else
		madlibs['content'] = client.critique(
			CGI.unescape(article[:user]), 
			CGI.unescape(article[:title]), 
			CGI.unescape(article[:body])
		)

		if madlibs['content'] =~ /Success/ then
			madlibs['content'] = "<IMG src=\"throbber.gif\"> " + madlibs['content']
		else
			madlibs['meta'] = ""
		end
	end

	madlibs['content'] = "<DIV class=\"content\">#{madlibs['content']}</DIV><BR>\n" 

	madlib(File.read("./res/bare.html"), madlibs)
end

end
