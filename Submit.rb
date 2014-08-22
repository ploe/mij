#! /usr/bin/ruby

# Submit is the Sumbmission form, that users use to add their 
# submissions to the site.
# It uses the resource form.html as its template page
module Submit

def Submit.render(params)
	madlib File.read("res/form.html"), {
		'prompt' => prompt,
		'tatl' => params[:tatl],
		'title' => 'submit',
		'title-input' => "<P><INPUT type=\"text\" name=\"article[title]\" id=\"title\" placeholder=\"Title\"></P>\n",
		'verbs' => 
			"<DIV class=\"verbs\">\n" +
			"<BUTTON formmethod=\"post\" id=\"preview\" formaction=\"./post\">Submit</BUTTON>\n" +
			"</DIV>"
	}
end

private

def Submit.prompt
	[
		"Put words here", 
		"Prosaic mutterings thus;",
		"Verse goes here.",
		"Skillful wordery, if you must...",
		"Text",
		"Paths of inscribed phonemes",
		"Lexemic nests. Rendered!",
		"Syntax bound tokens?",
		"Compounded sentences.",
		"Interleaved stanzas.",
		"P-p-p-paragraphs...",
		"How about a cheeky little narrative?",
		"A poem is fine too.",
		"Vent spleen here.",
		"Stick a story in me!",
		"Lorem ipsum ad nauseum bullshit etcetera lorem ipsum...",
		"Interpolate yer art",
	].sample
end

end
