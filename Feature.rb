#! /usr/bin/ruby

module Feature

def Feature.post(params)
	user = escape_param(params[:user])
	article = escape_param(params[:article])

	User.feature(user['text'], article['text'])
end

def Feature.get(params)
	user = escape_param(params[:user])
	article = escape_param(params[:article])

	madlib File.read('res/confirmation.html'), {
		'domain' => params[:domain],
		'favicon' => params[:favicon],
		'prompt' => "feature <A href=\"/article?user=#{user['cgi']}&article=#{article['cgi']}\">#{article['html']}</A> by <A href=\"/profile?user=#{user['cgi']}\">#{user['html']}</A> - ey?",
		'tatl' => params[:tatl],
		'title' => "feature #{article['html']} by #{user['html']}?",
	
		'maru' => "<BUTTON id=\"maru\" formaction=\"/feature\" formmethod=\"post\">for real</BUTTON>",
		'batsu' => "<BUTTON id=\"batsu\" formaction=\"/article\" formmethod=\"get\">hell no</BUTTON>",
		'hidden' => 
			"<INPUT type=\"hidden\" name=\"user\" value=\"#{user['cgi']}\">\n" +
			"<INPUT type=\"hidden\" name=\"article\" value=\"#{article['cgi']}\">",
	}
end

private

def Feature.escape_param(param)
	{
                'cgi' => param,
                'text' => CGI.unescape(param),
                'html' => CGI.escapeHTML(CGI.unescape(param))
        }
end

end
