module Profile

def Profile.get(params)
	Profile.set_defaults(params)
	madlib(File.read("res/bare.html"), {
		'domain' => params[:domain],
		'favicon' => params[:favicon],
		'tatl' => params[:tatl],
		'title' => "#{CGI.unescape(params[:user]).downcase}'s profile",
		'content' => Profile.content(params),
	})
end

private

def Profile.content(params)
	content = Dynamo.new
	content.append({
		'tag' => "DIV",
		'content' => "<STRONG>#{CGI.unescape(params[:user]).downcase}'s profile</STRONG>",
		'attributes' => {
			'class' => "content",
		},
	})
	content.append("<BR>\n\n")

	if User.count_featured(CGI.unescape(params[:user])) > 0 then content.append(Profile.render_featured(params)) end
	if User.count_submissions(CGI.unescape(params[:user])) > 0 then content.append(Profile.render_submissions(params)) end

	content.to_s
end

# render_submissions and render_featured are largely duplicated
def Profile.render_submissions(params)
	user = CGI.unescape(params[:user])

	submissions = User.fetch_submissions(user)
	submissions.sort_by! do |s|
		s[params['submissions_sortby']]
	end
	if params['submissions_order'] == "des" then submissions.reverse! end

	yours = false
	if params[:client] and user == params[:client].pseudonym then
		yours = true
	end

	submissions = Profile.render_articles(yours, submissions)

	href = Dynamo.href("/profile", {
		'user'  => user,
		"featured_order" => params['featured_order'],
		"featured_sortby" => params['featured_sortby'],	
	})

	Profile.render_articletable(params, yours, "submissions", href, submissions)
		.sub(/<\/STRONG><\/A>/, "<IMG src=\"#{params['submissions_order']}.png\"></STRONG></A>")
end

def Profile.render_featured(params)
	user = CGI.unescape(params[:user])

	featured = User.fetch_featured(user)
	featured.sort_by! do |s|
		s[params['featured_sortby']]
	end

	if params['featured_order'] == "des" then featured.reverse! end
	client = ""

	yours = false
	if params[:client] and user == params[:client].pseudonym
		yours = true
	end

	featured = Profile.render_articles(yours, featured)

	href = Dynamo.href("/profile", {
		'user'  => user,
		"submissions_order" => params['submissions_order'],
		"submissions_sortby" => params['submissions_sortby'],	
	})

	Profile.render_articletable(params, yours, "featured", href, featured)
		.sub(/<\/STRONG><\/A>/, "<IMG src=\"#{params['featured_order']}.png\"></STRONG></A>")
end

def Profile.set_defaults(params)
	if not params['submissions_sortby'] then params['submissions_sortby'] = "updated" end
	if not params['featured_sortby'] then params['featured_sortby'] = "updated" end

	if not params['submissions_order'] then params['submissions_order'] = "des" end
	if not params['featured_order'] then params['featured_order'] = "des" end
end

def Profile.render_articletable(params, yours, table, href, articles)
	content = Dynamo.new

	content.append("<STRONG>#{table}</STRONG><A name=\"#{table}\"><BR><BR></A>")
	content.tr_head(params, table, href, %w(Article Added Updated Buzz))

	articles.each do |a|
		content.tr_data(a, "data", %w(title added updated buzz))
	end

	content.wrap("TABLE", {
		'class' => "submissionslist",
	})

	if yours then
		content.append("<BR>") 
		verbs = Dynamo.new.append({
			'tag' => "BUTTON",
			'content' => "Delete 'em",
			'attributes' => {
				'id' => "remove#{table}",
				'formaction' => "/remove#{table}",
				'formmethod' => "GET",
			}
		})

		verbs.wrap("DIV", {
			'class' => "verbs",
		})
		verbs.clear_float

		content.append(verbs.to_s)
		
		content.wrap("FORM") 
	end

	content.wrap("DIV", {
		'class' => "content",
	})
	content.append("<BR>\n\n")

	content.to_s
end

def Profile.render_articles(yours, articles)
	articles.each do |a|
		checkbox = Dynamo.new

		if yours then
			checkbox.append({
				'tag' => "INPUT",
				'attributes' => {
					'type' => 'checkbox',
					'name' => CGI.escape(a['title'])
				},
			})
		end

		a['title'] = Dynamo.new.a_href(checkbox.to_s + a['title'], "/article", {
			'user' => a['user'],
			'article' => a['title']
		}).to_s

		a['added'] = Time.at(a['added']).strftime("%d-%m-%Y %T")
		a['updated'] = Time.at(a['updated']).strftime("%d-%m-%Y %T")
	end

	articles
end

end
