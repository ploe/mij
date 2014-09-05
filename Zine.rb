module Zine

def Zine.get(params)
	madlib(File.read("res/bare.html"), {
		'domain' => params[:domain],
		'favicon' => params[:favicon],
		'tatl' => params[:tatl],
		'title' => "featured",
		'content' => Zine.content
	})

end

private

def Zine.get_featured
	featured = []

	path = "/mij/featured/"
	Dir.foreach(path) do |user|
		if (user == "..") or (user == ".") then next end

		Dir.foreach(path + user) do |article|
			if (article == "..") or (article == ".") then next end
			featured.push(User.fetch_article(CGI.unescape(user), CGI.unescape(article)))
		end
	end

	featured.sort_by! do |f|
		f['added']
	end
	featured.reverse!

	featured
end

def Zine.content
	featured = Zine.get_featured	

	output = ""
	featured.each do |f|
		output += render_content(f)
	end

	output
end

def Zine.render_content(f)
	content = Dynamo.new

	user = Dynamo.new.a_href(f['html-user'], "/profile?user=#{f['cgi-user']}")
	article = Dynamo.new.a_href(f['html-title'], "/article?user=#{f['cgi-user']}&article=#{f['cgi-title']}")

	content.append("<DIV class=\"content\">\n")
	content.append({
		'tag' => 'DIV',
		'content' => "<STRONG>#{article}</STRONG> by #{user}",
		'newline' => true, 
		'attributes' => { 
			'class' => 'chunk', 
		} 		
	})

	content.append({
		'tag' => 'DIV',
		'content' => "#{f['body']}",
		'newline' => true,
		'attributes' => {
                        'class' => 'chunk',
                } 
	})

	content.append("<BR>\n")
	content.append({
                'tag' => 'DIV',
                'content' => Dynamo.new.a_href("View as Submission", "/article?user=#{f['cgi-user']}&article=#{f['cgi-title']}"),
                'newline' => true,
		'attributes' => {
                        'class' => 'verbs',
                }
	})

	content.clear_float	
	content.append("</DIV><BR>\n\n")	
end

end
