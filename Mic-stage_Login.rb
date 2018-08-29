def login(session, input1="", input2="", live=false)
	if(live)
		session.visit("http://micapp1")
	else
		session.visit("http://mic-stage02")
	end
	authenticate(session.driver.browser, input1, input2)
	# check that we have logged on correctly
	sleep(3)
	if(session.has_css?("html body#shell form#aspnetForm div#outer div#outer-left div#logo-top"))
		puts "Successfully logged onto Hub!"
	else
		puts "Failed to log onto Hub"
		exit -1
	end
end

def authenticate(browser, input1="", input2="") # Now have to send in usename and password every time we authenticate
	browser.switch_to.alert.send_keys(input1)
	browser.switch_to.alert.send_keys("\ue004"+input2)
	browser.switch_to.alert.accept()
end
