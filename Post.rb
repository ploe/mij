#! /usr/bin/ruby

# The post module is used for submitting submissions, render is basically
# the process that dumps their piece on the server
module Post

require "./mij.rb"

def Post.render(params, user)
	article = params[:article]
	prompt = "Post: User not logged in. Wait... wot?"
	if user then
		prompt = user.post(CGI.unescape(article['title']), CGI.unescape(article['body']))
	end

	meta = ""
	if prompt =~ /Success/i then
		meta = meta_refresh(2, "/article?user=#{CGI.escape(user.pseudonym)}&article=#{CGI.escape(article['title'])}")
		prompt = "<IMG src=\"/throbber.gif\"> " + prompt
	end

	madlib File.read("res/bare.html"), {
		'content' => "<DIV class=\"content\"><P>#{prompt}</P></DIV><BR>",
		'meta' => meta,
		'tatl' => Tatl.render(user),
		'title' => prompt,
	}
end

end
