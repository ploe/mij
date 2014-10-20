module RemoveArticle

def RemoveArticle.get(params)
	madlib(File.read("res/bare.html"), {
		'domain' => params[:domain],
		'favicon' => params[:favicon],
		'tatl' => params[:tatl],
		'title' => "toot toot toot",
		'content' => RemoveArticle.render_content(params),
	})
end

def RemoveArticle.render_content(params)
	articles = []

	if params[:client] then
		if params[:table] == 'featured' then
			articles = User.fetch_featured(params[:client].pseudonym)
		elsif params[:table] == 'submissions'
			articles = User.fetch_submissions(params[:client].pseudonym)
		end
	end


	content = Dynamo.new
	content.append({
		'tag' => "P",
		'content' => "You're wanting to delete <STRONG>these</STRONG> here articles, yeah?",
		'newline' => true,
	})
	content.append(RemoveArticle.render_checked(params, articles)).append("\n\n")
	content.append(RemoveArticle.render_confirm(params))
	content.clear_float
	content.wrap("FORM")
	

	content.wrap("DIV", {
		'class' => "content",
	}).append("<BR>\n")

	content.to_s
end

def RemoveArticle.render_checked(params, articles)
	checked = Dynamo.new
	articles.each do |a|
		if params[a['cgi-title']] then
		checked.append({
			'tag' => "LI",
			'content' => a['html-title'],
			'newline' => true
		})

		checked.append({
			'tag' => "INPUT",
			'newline' => true,
			'attributes' => {
				'type' => "hidden",
				'name' => a['cgi-title'],
				'value' => "on",
			}	
		})

		end
	end
	checked.wrap("UL")

	checked.to_s
end

def RemoveArticle.render_confirm(params)
	confirm = Dynamo.new.append({
		'tag' => "BUTTON",
		'content' => "yeah",
		'attributes' => {
			'id' => "remove#{params[:table]}",
			'formaction' => "/remove/#{params[:table]}",
			'formmethod' => "POST",
		}
	})

	confirm.wrap("DIV", {
		'class' => "verbs",
	}).append("\n")

	confirm.to_s

end

end
