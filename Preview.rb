module Preview

def Preview.get(params)
	madlib File.read("/mij/src/res/bare.html"), {
		'content' => Preview.render_content(params['article']['body']),
		'domain' => params[:domain],
		'favicon' => params[:favicon],
		'meta' => "",
		'title' => "preview article",
		'tatl' => params[:tatl],
	}

end

def Preview.render_content(body)
	content = Dynamo.new.append(GitHub::Markdown.render_gfm(CGI.escapeHTML(CGI.unescape(body))))
	content.wrap("DIV", {
		'class' => "content",
	}).append("<BR>").to_s
end

end
