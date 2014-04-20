class BoardIndex

def render(err = nil)
	page = ""
	if (err) != nil and (err.class == Array) then page = err.join("\n\n") + "\n\n" end
	Dir.foreach("/mij/boards/").sort.each { |board|
		if board[0] == "." then next end
		page += "#{board}\n\n"
	}
	GitHub::Markdown.render_gfm(page)
end

end


