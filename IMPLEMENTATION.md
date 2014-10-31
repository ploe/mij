# public/

HTTP docroot, default of Sinatra
# res/

Short for resources. HTML templates that I don't want on the public HTTP site. Like the private method of a class or something...

# main.rb

Our Sinatra routes. All of the data requires a little massaging before we hand it off to the modules. The get_user method does the appropriate calls to authenticate us. It returns nil.

Most routes are simply implemented as modules with a render function. For instance "get '/submit'" (the form the User will submit a piece of writing on) would be implemented in the module Submit.rb - and the function that pieces together the HTML template and live parts is render.

# Madlib.rb

madlib is a template function. It's a simple search and replace which takes all the keys from a hash and replaces instances of them in the supplied string with the corresponding values in the hash. A key is delimited in the string as a HTML comment. For instance hash['key'] would be replace <!-- {key} -->

The benefit of this over something like 'erb' is that all my bog standard HTML literate tools, like my browser, don't need anything special to read my templates. Any dynamic elements are simply stitched together by the appropriate module. I like how straightforwad/clean this approach is.

# Dynamo.rb

I changed approach slightly when generating dynamic HTML elements. Whereas previously I used flat HTML in the Ruby source, I've now written a bunch of macros wrapped up in a class that are used to render the objects. The idea is that you build the dynamic objects (**Dynamos**) by appending chunks of HTML to them. You then drop them on the prerendered template.

## def append(params)

```ruby
dynamo = Dynamo.new

dynamo.append({
	'tag' => "P",
	'content' => "The content that gets wrapped in P tags",
	'newline' => true,
	'attributes' => {
		'class' => "css_class",
		'id' => "paragraph_id",
		'hidden' => true,
	}
})

dynamo.append("<BR><P>Another paragraph!</P><BR>")
```

**tag:** The HTML element you want to render *e.g. DIV, P, SPAN, IMG, A, etc.*

**content:** The string you want sandwiching between your tags. If you ignore this field you will only have one tag, for if you want to render IMG or something like it.

**newline:** If true there will be a newline after this block of HTML. For pretty printing.

**attributes:** The HTML element attributes. String values are inserted between quotes, boolean true values will only render the key.

# Tatl.rb

The navigation bar at the top of the screen. Pretty much just two flat HTML templates kept in the one place for convenience. It renders all the user related stuff if the user is logged in. Otherwise it misses that gear out and has the option to log in. Perceptive readers might notice this module is named for Link's fairy in The Legend of Zelda: Majora's Mask. This is because the navigation bar in my blog is called Navi, Link's fairy in the previous game.

# User.rb

## User type

The User type is representative of what a user can do on the platform. Its methods implement the persistent chunks of User interaction. Its implementation kind of descibes the analogy between what the User thinks they are doing on the platform with what they're actually doing to the Unix beneath. It's all files and symlinks under there - because I like it that way.

I've tried to refrain from rendering huge chunks of pages in there. Methods can return a string for rendering in to the page. This is normally flavourful - the only constant is the string will contain the pattern "Success" if the method was successful/didn't fail. For each failure the string is unique, so that if something arises that may need debugging it's a case of searching the module for that there pattern.

## User module

This is essentially encapsulates our directory of User types.

# 'Everything else'.rb

Everything else is a one-shot module with a render function. It'll typically dredge in an HTML template from 'res/' and replace all the dynamic bits in it with madlib. It is implemented as a module rather than just being dumped in main.rb should we need to bolt any bits on down the line. A little decentralised whilst the platform is small... but not overtly confusing.
