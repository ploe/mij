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
		'content' => "<STRONG>#{article}</STRONG> by #{user} #{Zine.render_date(f['added'])}",
		'newline' => true, 	
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
                'content' => Zine.render_articleurl(f),
                'newline' => true,
		'attributes' => {
                        'class' => 'verbs',
                }
	})

	content.clear_float	
	content.append("</DIV><BR>\n\n")	
end

def Zine.render_articleurl(f)
	tmp = Dynamo.new
	if f['buzz'] == 1 then
		tmp.a_href("there is #{f['buzz']} critique - #{Zine.holy_peek}?", "/article?user=#{f['cgi-user']}&article=#{f['cgi-title']}")
	elsif f['buzz'] > 1 then 
		tmp.a_href("there are #{f['buzz']} critiques - #{Zine.holy_peek}?", "/article?user=#{f['cgi-user']}&article=#{f['cgi-title']}")
	else
		tmp.append("nope - no critiques")
	end

	tmp.to_s
end

def Zine.render_date(time)
	added = Time.at(time).strftime("%d-%m-%Y %T")
	Dynamo.new.append({
		'tag' => "SPAN",
		'content' => "[#{added}]",
		'attributes' => {
			'class' => "date"
		}
	})
end



def Zine.holy_peek
	[
		"take a peek",
		"have a look-see",
		"let's have a nosy",
		"have a butchers",
		"peruse",
		"have a gander",
		"stare at 'em",
		"wanna read",
		"give 'em a once-over",
		"inspect",
		"investitigate",
		"investigate",
		
	].sample
end

end
