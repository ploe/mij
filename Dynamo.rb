#! /usr/bin/ruby

class Dynamo

def initialize
	@value = ""
end

# incredibly agnostic html rendering function, give it a raw string or a 
# hash and watch it work its magic. The idea is the Dynamo is a dynamic 
# widget on the page.
def append(params)
	if params.is_a? String then 
		@value += params
	elsif params.is_a? Hash then
		render_hash(params)
	end

	@value
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
	if params['tag'] then 
		@value += "<#{params['tag']}{attributes}>"

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
		@value.sub!(/{attributes}/, attributes)
	
	end

	if params['content'] then @value += "#{params['content']}" end

	if (params['tag'] != nil) and (params['content'] != nil) then @value += "</#{params['tag']}>" end

	@value += "\n"
end

end
