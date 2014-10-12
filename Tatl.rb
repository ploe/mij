#! /usr/bin/ruby

module Tatl

# Renders what would be the navbar in the top right
def  Tatl.render(user)
	if user then logged_in(user.pseudonym)
	else logged_out end
end

private

def Tatl.logged_in(user)

	if user == "" then user = "register" end

<<NAVBAR_IN
<BR>
<DIV class="stuffcontainer" align="right">
<SPAN class="userstuff"><A href="/zine">featured</A></SPAN> 
<SPAN class="userstuff"><A href="/submit">submit</A></SPAN>  
<SPAN class="userstuff"><A href=\"/submissions\">submissions</A></SPAN> 
<SPAN class="userstuff"><A href=\"/profile?user=#{CGI.escape(user)}\">#{user.downcase}</A></SPAN> 
<SPAN class="userstuff"><A href="/page?src=about">about</A></SPAN> 
<SPAN class="userstuff"><A href="/logout">logout</A></SPAN>
</DIV>
<BR>
NAVBAR_IN

end

def Tatl.logged_out

<<NAVBAR_OUT
<BR>
<DIV class="stuffcontainer" align="right">
<SPAN class="userstuff"><A href="/zine">featured</A></SPAN> 
<SPAN class="userstuff"><A href=\"/submissions\">submissions</A></SPAN> 
<SPAN class="userstuff"><A href="/page?src=about">about</A></SPAN> 
<SPAN class="userstuff"><A href="/page?src=login">login</A></SPAN>
</DIV>
<BR>
NAVBAR_OUT

end


end
