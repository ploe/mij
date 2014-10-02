module Profile

def Profile.get(params)
	Profile.set_defaults(params)
	madlib(File.read("res/bare.html"), {
		'domain' => params[:domain],
		'favicon' => params[:favicon],
		'tatl' => params[:tatl],
		'title' => "#{CGI.unescape(params[:user]).downcase}'s profile",
		'content' => Profile.their_profile(params),
	})
end

private

def Profile.content(params)
	Profile.their_profile(params)
end

def Profile.your_profile

end

def Profile.their_profile(params)
	content = Dynamo.new
	if User.count_featured(CGI.unescape(params[:user])) > 0 then content.append(Profile.their_featured(params)) end
	if User.count_submissions(CGI.unescape(params[:user])) > 0 then content.append(Profile.their_submissions(params)) end

	content.to_s
end

# their_submissions and their_featured are largely duplicated
def Profile.their_submissions(params)
	user = CGI.unescape(params[:user])

	submissions = User.fetch_submissions(user)
	submissions.sort_by! do |s|
		s[params['submissions_sortby']]
	end
	if params['submissions_order'] == "des" then submissions.reverse! end
	submissions = Profile.render_articles(submissions)

	href = Dynamo.href("/profile", {
		'user'  => user,
		"featured_order" => params['featured_order'],
		"featured_sortby" => params['featured_sortby'],	
	})

	content = Dynamo.new

	content.append("<P><STRONG>Submissions:</STRONG><A name=\"submissions\"></A></P>")
	content.tr_head(params, "submissions", href, %w(Article Added Updated Buzz))
	content.sub!(/<\/STRONG><\/A>/, "<IMG src=\"#{params['submissions_order']}.png\"></STRONG></A>")	

	submissions.each do |s|
		content.tr_data(s, "data", %w(title added updated buzz))				
	end

	content.wrap("TABLE", {
		'class' => "submissionslist",
	})

	content.wrap("DIV", {
		'class' => "content",
	})
	content.append("<BR>\n\n")

	content.to_s
end

def Profile.their_featured(params)
	user = CGI.unescape(params[:user])

	featured = User.fetch_featured(user)
	featured.sort_by! do |s|
		s[params['featured_sortby']]
	end
	if params['featured_order'] == "des" then featured.reverse! end
	featured = Profile.render_articles(featured)

	href = Dynamo.href("/profile", {
		'user'  => user,
		"submissions_order" => params['submissions_order'],
		"submissions_sortby" => params['submissions_sortby'],	
	}) 

	content = Dynamo.new
	content.append("<P><STRONG>Featured:</STRONG><A name=\"featured\"></A></P>")
	content.tr_head(params, "featured", href, %w(Article Added Updated Buzz))
	content.sub!(/<\/STRONG><\/A>/, "<IMG src=\"#{params['featured_order']}.png\"></STRONG></A>")	

	featured.each do |s|
		content.tr_data(s, "data", %w(title added updated buzz))				
	end

	content.wrap("TABLE", {
		'class' => "submissionslist",
	})

	content.wrap("DIV", {
		'class' => "content",
	})
	content.append("<BR>\n\n")

	content.to_s
end

def Profile.set_defaults(params)
	if not params['submissions_sortby'] then params['submissions_sortby'] = "updated" end
	if not params['featured_sortby'] then params['featured_sortby'] = "updated" end

	if not params['submissions_order'] then params['submissions_order'] = "des" end
	if not params['featured_order'] then params['featured_order'] = "des" end
end

def Profile.render_articles(articles)
	articles.each do |a|
		a['title'] = Dynamo.new.a_href(a['title'], "/article", {
			'user' => a['user'],
			'article' => a['title']
		}).to_s

		a['added'] = Time.at(a['added']).strftime("%d-%m-%Y %T")
		a['updated'] = Time.at(a['updated']).strftime("%d-%m-%Y %T")
	end

	articles
end

end
