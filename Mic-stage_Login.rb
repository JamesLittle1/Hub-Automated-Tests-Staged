def login(session, config, input1="", input2="", live=false)
	if(live)
		session.visit("http://micapp1")
	else
		begin
			session.visit("http://mic-stage02")
		rescue
			session.visit("http://10.16.50.151")
		end
	end
	authenticate(session.driver.browser, input1, input2)
	# check that we have logged on correctly
	for i in 0..config['authentication_load']
		if(session.has_css?("html body#shell form#aspnetForm div#outer div#outer-left div#logo-top"))
			puts "Successfully logged onto Hub!"
			return true
		else
			sleep(1)
		end
	end
	return false
end

def authenticate(browser, input1="", input2="") # Now have to send in usename and password every time we authenticate
	browser.switch_to.alert.send_keys(input1)
	browser.switch_to.alert.send_keys("\ue004"+input2)
	browser.switch_to.alert.accept()
end

def open_search_customer_frame(session, config, input1="", input2="", live=false)
	if(live)
		session.visit("http://micapp1/Webforms/CustomerManagement/frmCustomerActionSelect.aspx")
	else
		begin
			session.visit("http://mic-stage02/Webforms/CustomerManagement/frmCustomerActionSelect.aspx")
		rescue
			session.visit("http://10.16.50.151/Webforms/CustomerManagement/frmCustomerActionSelect.aspx")
		end
	end
	authenticate(session.driver.browser, input1, input2)
	for i in 0..config['authentication_load']
		if(session.has_css?("#ctl00_MainArea_lblTitle"))
			puts "Successfully logged onto Hub!"
			return true
		else
			sleep(1)
		end
	end
	return false
end
