#! /usr/bin/ruby

module Tatl

# Renders what would be the navbar in the top right
def  Tatl.render(user)
	if user then logged_in
	else logged_out end
end

private

def Tatl.logged_in

<<NAVBAR_IN
<DIV class="stuffcontainer" align="right">
<SPAN class="userstuff">featured</SPAN> 
<SPAN class="userstuff"><A href="/submit">submit</A></SPAN>  
<SPAN class="userstuff">submissions</SPAN> 
<SPAN class="userstuff">[pseudonym]</SPAN> 
<SPAN class="userstuff"><A href="/page?src=about">about</A></SPAN> 
<SPAN class="userstuff"><A href="/logout">logout</A></SPAN>
</DIV>
<BR>
NAVBAR_IN

end

def Tatl.logged_out

<<NAVBAR_OUT
<DIV class="stuffcontainer" align="right">
<SPAN class="userstuff">featured</SPAN> 
<SPAN class="userstuff">submissions</SPAN> 
<SPAN class="userstuff"><A href="/page?src=about">about</A></SPAN> 
<SPAN class="userstuff"><A href="/page?src=login">login</A></SPAN>
</DIV>
<BR>
NAVBAR_OUT

end


end
