#! /usr/bin/ruby

class Preview

require "github/markdown" 

def render(article)
	GitHub::Markdown.render_gfm(article[:body])
end

end
