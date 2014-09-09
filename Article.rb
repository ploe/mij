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
		added = Article.render_date(article['added'])
		content = 
			"<DIV class=\"content\">\n" +
			"<DIV class=\"chunk\">" +
			"<STRONG>#{article['html-title']}</STRONG>" +
			" by <A href=\"/profile?user=#{article['cgi-user']}\">#{article['html-user']}</A> #{added}" +
			"</DIV>\n" +
			"<DIV class=\"chunk\">\n#{article['body']}\n</DIV><BR>\n" +
			render_verbs(article, client) +
			"</DIV><BR>\n" +
			render_critiques(article['critiques'])
	end

	return content, meta
end

def Article.render_critiques(critiques)
	content = ""
	critiques.each do |c|
		tmp = Dynamo.new
	
		added = Article.render_date(c['added'])	
		tmp.append({
			'tag' => "DIV",
			'content' => "<A href=\"/profile?user=#{c['cgi-user']}\">#{c['html-user']}</A> #{Article.holy_says}... #{added}",
			'newline' => true,
		})
	
		tmp.append({
			'tag' => "DIV",
			'content' => "#{c['critique']}",
                        'newline' => true,
			'attributes' => {
				'class' => 'chunk',
			}
		})
		tmp.append("<BR>\n")
		content += tmp.to_s
	end


	# Wraps the content up in a content div
	if content != "" then 
		content = Dynamo.new.append({
			'tag' => "DIV",
                        'content' => content,
                        'attributes' => {
                                'class' => 'content',
                        }
		})

		content += "<BR>\n"
	end

	content
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

def Article.render_date(time)
	added = Time.at(time).strftime("%d-%m-%Y %T")
	Dynamo.new.append({
		'tag' => "SPAN",
		'content' => "[#{added}]",
		'attributes' => {
			'class' => "date"
		}
	})
end

private

def Article.holy_says
	[
		"says",
		"shouts",
		"whispers",
		"suggests",
		"opines",
		"orates",
		"soliloquizes",
		"s-s-s-stutters",
		"misspels",
		"reckons",
		"assumes",
		"puts out there",
		"puts forward",
		"moans that",
		"coughs up",
		"spews out",
		"preaches",
		"prays",
		"articulates",
		"argues",
		"distills",
		"demonstrates",
		"dreams that",
		"dishes",
		"doles outs",
		"might've said",
		"types",
		"scribes",
		"writes",
		"draws",
		"summoned",
		"throws out",
		"presents",
		"reveals",
	].sample
end

end	
