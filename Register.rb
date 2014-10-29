module Register

def Register.post(params)
	prompt = params[:client].set_pseudonym(params[:pseudonym])
	meta = ""
	if prompt =~ /Success/ then
		meta = meta_refresh(4, "/zine")
		prompt.sub!(/^/, Dynamo.new.append({
			'tag' => "IMG",
			'attributes' => {
				'src' => "/throbber.gif",
				'alt' => "bonerific ;)",
			},
		}).to_s)
	end

	madlib File.read("/mij/src/res/bare.html"), {
		'content' => "<DIV class=\"content\"><P>#{prompt}</P></DIV><BR>",
		'domain' => params[:domain],
		'favicon' => params[:favicon],
		'meta' => meta,
		'tatl' => params[:tatl],
		'title' => prompt,
	}

end

end
