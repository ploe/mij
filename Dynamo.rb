#! /usr/bin/ruby

class Dynamo

def initialize
	@value = ""
end

# incredibly agnostic html rendering function, give it a raw string or a 
# hash and watch it work its magic. The idea is the Dynamo is a dynamic 
# widget on the page.
def write(params)
	if params.is_a? String then
                @value = params
        elsif params.is_a? Hash then
                @value = render_hash(params)
        end

	self
end

def append(params)
	if params.is_a? String then 
		@value += params
	elsif params.is_a? Hash then
		@value += render_hash(params)
	end

	self
end

# wrap takes the existing Dynamo and wraps it with the tag
def wrap(tag="", attributes=nil)
	write({
                'tag' => tag,
                'content' => to_s,
                'attributes' => attributes
        })
	$stderr.puts "#{tag} => #{to_s}"
	self
end

def a_href(content, href, params={})
	params.keys.each do |k|
		if href =~ /\?/ then
			href += "&amp;"
		else
			href += "?"
		end

		href += "#{CGI.escape(k.to_s)}=#{CGI.escape(params[k].to_s)}"
	end

	append({
		'tag' => "A",
		'content' => content,
		'attributes' => {
			'href' => href,
		}
	})

	self
end

def clear_float
	append({
                'tag' => "DIV",
                'content' => "",
                'attributes' => {
                        'style' => "clear: both",
                }
        })
	
	self
end

def to_s
	return @value
end

private

attr_accessor :value

# hash can have members content, tag and attributes
# content is a plain ol' string
# tag is the type of html element to render
# attributes are the attributes of the tag, this is a nested hash
# the members of attributes can either be a string or boolean true
# string renders as: key="value" e.g. href="/home"
# true renders as: key e.g. checked
def render_hash(params)
	value = ""
	if params['tag'] then 
		value += "<#{params['tag']}{attributes}>"

		attributes = ""
		if params['attributes'].is_a? Hash then
			params['attributes'].keys.each do |k|
				v = params['attributes'][k]
				if v.is_a?(String) then 
					attributes += " #{k}=\"#{v}\""
				elsif v == true then
					attributes += " #{k}";
				end
			end
		end
		value.sub!(/{attributes}/, attributes)
	
	end

	if params['content'] then value += "#{params['content']}" end

	if (params['tag'] != nil) and (params['content'] != nil) then value += "</#{params['tag']}>" end

	if params['newline'] then value += "\n" end

	value
end

end
