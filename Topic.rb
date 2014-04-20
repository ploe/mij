#! /usr/bin/ruby

class Topic

# Topic returns the Sinatra response and a list of errors that occured
def render(params)
	path = get_paths(params)
	if failed?(path) then return BoardIndex.new.render(path) end

	template = get_template	
end

private 

# Returns a hash containing the paths or a list of the errors
def get_paths(params)
	# Have the parameters been specified
	err = []
	if (not params[:board]) then err.push("Topic: No board specified") end
	if (not params[:topic]) then err.push("Topic: No topic specified") end
	if (err.length > 0) then return err end

	board = URI.decode(params[:board])
	topic = URI.decode(params[:topic])

	# Build the literal paths up
	path = {
		:board => "/mij/boards/" + board,
		:decoded => {:board => board, :topic => topic}
	}
	path[:topic] = path[:board] + "/" + topic

	# Do they exist?
	if (not File.directory?(path[:board])) then
		return ["Topic: Board \"#{board}\" not found"]
	elsif (not File.directory?(path[:topic])) then
		return ["Topic: Topic \"#{topic}\" not found"]
	end

	path
end

def get_template(params)
	# Use ./res/topic.html
	""
end

def render_posts
	# For each post render a HTML blob
	""
end

# Since we return an array of errors
def failed?(param)
	return param.class == Array
end

end
