module Zine

def Zine.get(params)
	madlib(File.read("res/bare.html"), {
		'domain' => params[:domain],
		'favicon' => params[:favicon],
		'tatl' => params[:tatl],
		'title' => "featured",
		'content' => Zine.content(params)
	})

end

private

def Zine.get_featured(page=1, perpage)
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

	page = page.to_i - 1
	(page * perpage).times do
		featured.shift
	end

	featured
end

def Zine.content(params)
	perpage = 10

	if not params['page'] then params['page'] = 1 end
	featured = Zine.get_featured(params['page'], perpage)	
	output = ""

	perpage.times do
		f  = featured.shift
		if not f then break end

		output += render_content(f)
	end

	nav = Zine.render_nav(params['page'].to_i, featured.length, perpage)
	nav + output + nav
end

def Zine.render_content(f)
	content = Dynamo.new

	# heading
	content.a_href(f['html-title'], "/article", {
		'user' => "#{f['user']}",
		'article'=> "#{f['title']}",
	})
	content.wrap("STRONG")
	content.append(" by ")
	content.a_href(f['html-user'], "/profile", {
                'user'=> "#{f['user']}",
        })
	content.append("#{Zine.render_date(f['added'])}")

	# body
	content.append({
		'tag' => 'DIV',
		'content' => "#{f['body']}",
		'newline' => true,
		'attributes' => {
                        'class' => 'chunk',
                } 
	})

	# verbs
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
	content.wrap("DIV", {
		'class' => 'content'
	})
	content.append("<BR>\n\n")
	content.to_s
end

def Zine.render_articleurl(f)
	tmp = Dynamo.new
	if f['buzz'] == 1 then
		tmp.a_href("there is #{f['buzz']} critique - #{Zine.holy_peek}?", "/article?user=#{f['cgi-user']}&amp;article=#{f['cgi-title']}")
	elsif f['buzz'] > 1 then 
		tmp.a_href("there are #{f['buzz']} critiques - #{Zine.holy_peek}?", "/article?user=#{f['cgi-user']}&amp;article=#{f['cgi-title']}")
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

def Zine.render_nav(page, len, perpage)
	nav = Dynamo.new

	if page > 1 then
		prev = Dynamo.new.a_href("prev", "/zine", {
                	'page'=> (page-1).to_s,
        	})
		prev.wrap("SPAN", {
			'style' => "float: left;",
		})
		nav.append(prev.to_s)
	end

	total = ((page * perpage) + len) / perpage
	if ((page * perpage + len) % perpage) != 0 then total += 1 end
 
	if page < total then
		nextp = Dynamo.new.a_href("next", "/zine", {
                        'page'=> (page+1).to_s,
                })

		nextp.wrap("SPAN", {
			'style' => "float: right;",
		})
		nav.append(nextp.to_s)
	end

	nav.append({
		'tag' => "DIV",
		'content' => "Page #{page} of #{total}",
		'attributes' => {
			'style' => "text-align: center;",
		}
	})

	nav.clear_float
	nav.wrap("DIV", {
		'class' => "content",
	}).append("<BR>\n\n")

	nav.to_s
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
