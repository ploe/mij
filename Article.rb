#! /usr/bin/ruby

module Article

def Article.render(params)
	client = params[:client]
	article = CGI.unescape(params[:article])
	user = CGI.unescape(params[:user])

	
	content, meta = render_submission(user, article, client)

	madlib File.read("res/bare.html"), {
		'content' => content,
		'meta' => meta,
		'title' => "#{CGI.escapeHTML(article)} by #{CGI.escapeHTML(user)}",
		'tatl' => params[:tatl],
	}
end

def Article.render_submission(user, article, client)
	article = User.fetch_article(user, article)
	meta = ""

	if article['body'] == nil then
		content = article.to_s + "<DIV class=\"content\"><IMG src=\"/throbber.gif\"> Article: I'm afraid \"#{article['html-title']}\" by #{article['html-user']} doesn't exist. Soz, pal!</DIV>"
		meta = meta_refresh(4, "/page?src=about")
	else
		content = 
			"<DIV class=\"content\">\n" +
			"<DIV class=\"chunk\">" +
			"<STRONG>#{article['html-title']}</STRONG>" +
			" by <A href=\"/profile?user=#{article['cgi-user']}\">#{article['html-user']}</A>" +
			"</DIV>\n" +
			"<DIV class=\"chunk\">\n#{article['body']}\n</DIV><BR>\n" +
			render_verbs(article, client) +
			"</DIV><BR>\n" +

			render_critiques(article['critiques'])
	end

	return content, meta
end

def Article.render_critiques(critiques)
	"<!--" + critiques.to_s + "-->"	
end

def Article.render_verbs(article, client)
	content = ""
	if client and client.authentic then
		content = "<DIV class=\"verbs\">\n"
		content += 
			"<FORM>\n" +
			"<INPUT type=\"hidden\" name=\"article\" value=\"#{article['title']}\">\n" +
			"<INPUT type=\"hidden\" name=\"user\" value=\"#{article['html-user']}\">\n" +
			"<BUTTON id=\"critique\" formaction=\"/critique\" formmethod=\"get\">critique</BUTTON>\n"

		if client.perks['editor'] then 
			content += " <BUTTON>feature</BUTTON>"
		end

		if client.perks['janitor'] or client.perks['editor'] then
			content += " <BUTTON>remove</BUTTON>" 
		end

		content += "</DIV><DIV style=\"clear: both\"></DIV></FORM>\n"
	end
	content
end

end	
