#! /usr/bin/ruby

module Article

def Article.render(params)
	client = params[:client]
	article = CGI.unescape(params[:article])
	user = CGI.unescape(params[:user])

	
	content, meta = render_submission(user, article, client)

	madlib File.read("res/bare.html"), {
		'content' => content,
		'domain' => params[:domain],
		'favicon' => params[:favicon],
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
		content = 
			"<DIV class=\"verbs\">\n<FORM>\n" +
			"<INPUT type=\"hidden\" name=\"user\" value=\"#{article['html-user']}\">\n" +
			"<INPUT type=\"hidden\" name=\"article\" value=\"#{article['title']}\">\n"

		if article['path'] !~ /featured/ then
			if client.perks['editor'] then 
				content += " <BUTTON  id=\"feature\" formaction=\"/feature\" formmethod=\"get\">feature</BUTTON>\n"
			end

			content += "<BUTTON id=\"critique\" formaction=\"/critique\" formmethod=\"get\">critique</BUTTON>\n"

		end

		if client.perks['janitor'] or client.perks['editor'] then
			content += " <BUTTON id=\"feature\" formaction=\"/feature\" formmethod=\"post\">flag user</BUTTON>" 
		end

		content += "</DIV><DIV style=\"clear: both\"></DIV></FORM>\n"
	end
	content
end

end	
