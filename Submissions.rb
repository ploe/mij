#! /usr/bin/ruby

module Submissions

def Submissions.render(params, tatl)
	path = "/mij/submissions/"
	submissions = []
	Dir.foreach(path) do |user|
		if user =~ /^\./ then next end

		Dir.foreach(path + user) do |article|
			if article =~ /^\./ then next end
			sub = {
				'user' => user,
				'article' => article,
				'updated' => File.mtime("#{path}#{user}/#{article}").to_i,
				'added' => File.mtime("#{path}#{user}/#{article}/#{user}").to_i,
				'buzz' => User.count_buzz(user, article),
			}
			submissions.push(sub)
		end
	end

	sort = params[:sort] || "updated"
	submissions.sort_by! do |sub|
		if sub[sort].is_a?(String) then sub[sort].downcase
		else sub[sort] end
	end

	order = params[:order] || "desc"
	if order == "des" then submissions.reverse! end

	madlib(File.read("res/bare.html"), {
		'tatl' => tatl,
		'content' => "<DIV class=\"content\">" + render_list(submissions, params) + "</DIV><BR>\n",
	})
end

def Submissions.render_head(params)
	sort = params[:sort] || "updated"
	order = params[:order] || "des"

	table = "<TR class=\"head\">"	

	%w(article user added updated buzz).each do |name|
		table += "<TD class=\"#{name}\">"
		tmp = order
		glyph = ""
		if name == sort then
			table += "<STRONG>"
			glyph = "(#{order})"
			if tmp == "asc" then
				tmp = "des"
			else
				tmp = "asc" 
			end
		end
		
		table += "<A href=\"/submissions?sort=#{name}&order=#{tmp}\">#{name.capitalize} #{glyph}</A>"
		if name == sort then table += "</STRONG>" end
		table += "</TD>"
	end
	table += "</TR>\n"	
end

def Submissions.render_data(sub)
	table = "<TR class=\"data\">"
	table += "<TD class=\"article\"><A href=\"/submission?user=#{URI.encode(sub['user'])}&article=#{URI.encode(sub['article'])}\">#{sub['article']}</A></TD>"
	table += "<TD class=\"user\"><A href=\"/profile?user=#{URI.encode(sub['user'])}\">#{sub['user']}</A></TD>"
	table += "<TD class=\"added\">#{Time.at(sub['added']).strftime("%d-%m-%Y %T")}</TD>"
	table += "<TD class=\"updated\">#{Time.at(sub['updated']).strftime("%d-%m-%Y %T")}</TD>"
	table += "<TD class=\"buzz\">#{sub['buzz']}</TD>"
	table += "</TR>\n"
end

def Submissions.render_list(subs, params)
	table = "<TABLE class = \"submissionslist\">\n"	
	table += render_head(params)

	subs.each do |sub|
		table += render_data(sub)
	end

	table += "</TABLE>\n"
end

end
