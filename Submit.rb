#! /usr/bin/ruby

# Submit is the Sumbmission form, that users use to add their 
# submissions to the site.
# It uses the resource form.html as its template page
module Submit

def Submit.render(tatl)
	page = File.read("res/form.html")
	madlibs = {
		'prompt' => prompt,
		'tatl' => tatl,
		'title' => 'submit',
	}

	madlibs.keys.each do |tag|
		page.gsub!(/<!-- {#{tag}} -->/, madlibs[tag])
	end

	page
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
