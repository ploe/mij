#! /usr/bin/ruby

# The post module is used for submitting submissions, render is basically
# the process that dumps their piece on the server
module Post

require "./mij.rb"

def Post.render(params)
	client = params[:client]
	article = params[:article]
	prompt = "Post: User not logged in. Wait... wot?"
	if client then
		prompt = client.post(CGI.unescape(article['title']), CGI.unescape(article['body']))
	end

	meta = ""
	if prompt =~ /Success/i then
		url = "/article?user=#{CGI.escape(client.pseudonym)}&amp;article=#{CGI.escape(article['title'])}"
		meta = meta_refresh(4, url)
		prompt = "<IMG src=\"/throbber.gif\"> " + prompt
		Twitterer.post("New post: #{params[:protocol]}://#{params[:domain] + url}")
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
