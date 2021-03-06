# Method to search for all customers
def search_customers(session, config, input1="", input2="")
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Homepage", "load"){
		begin
			session.click_link("Search")
			session.accept_alert do
				session.click_link("All Customers")
				authenticate(session.driver.browser, input1, input2)
			end
		rescue Capybara::ModalNotFound, Selenium::WebDriver::Error::NoSuchAlertError
		end
	})
		return false
	end
	return true
end

def select_customer(session, config, pipeline=false, frame=false, override="")
	if(override == "")
		loop_times = 'loop_times_extended'
		timeout_threshold = 'timeout_threshold_extended'
	else
		loop_times = 'loop_times_override'
		timeout_threshold = 'timeout_threshold_override'
	end
	
	if(frame)
		press_search(session, config, pipeline, override)
	else
		session.within_frame(0) do
			press_search(session, config, pipeline, override)
		end
	end
	
	if(!wait_for_page_to_load(session, config, loop_times, timeout_threshold, "Search Customers results", "load"){
		if(frame)
			# if(session.has_css?("html body#main div#ctl00_MainArea_RadAjaxLoadingPanel1ctl00_MainArea_grdSearchResults.RadAjax.RadAjax_Default"))
				# raise "page is still loading"
			# end
			# if(session.find(:id, "ctl00_MainArea_grdSearchResults_ctl00")['innerHTML'].scan("There are no items to display.").count > 0)
				# puts "No items returned from search - try again"
				# press_search(session, config, pipeline, override)
			# end
			# cust_ids = session.find(:id, "ctl00_MainArea_grdSearchResults_ctl00")['innerHTML'].scan(/C\d\d\d\d\d\d/)
			# number = cust_ids.count - 1
			# session.find(:id, "ctl00_MainArea_grdSearchResults_ctl00__#{number}").click
			# begin
				# session.click_button("View")
			# rescue Net::ReadTimeout
			# end
			press_search_again_if_not_loaded(session, config, pipeline, override)
		else
			session.within_frame(0) do
				# if(session.has_css?("html body#main div#ctl00_MainArea_RadAjaxLoadingPanel1ctl00_MainArea_grdSearchResults.RadAjax.RadAjax_Default"))
					# raise "page is still loading"
				# end
				# if(session.find(:id, "ctl00_MainArea_grdSearchResults_ctl00")['innerHTML'].scan("There are no items to display.").count > 0)
					# puts "No items returned from search - try again"
					# press_search(session, config, pipeline, override)
				# end
				# session.find(:id, "ctl00_MainArea_grdSearchResults_ctl00__0").click
				# begin
					# session.click_button("View")
				# rescue Net::ReadTimeout
				# end
				press_search_again_if_not_loaded(session, config, pipeline, override)
			end
		end
	})
		return false
	end
	return true
end

def press_search_again_if_not_loaded(session, config, pipeline, override)
	if(session.has_css?("html body#main div#ctl00_MainArea_RadAjaxLoadingPanel1ctl00_MainArea_grdSearchResults.RadAjax.RadAjax_Default"))
		raise "page is still loading"
	end
	if(session.find(:id, "ctl00_MainArea_grdSearchResults_ctl00")['innerHTML'].scan("There are no items to display.").count > 0)
		puts "No items returned from search - try again"
		press_search(session, config, pipeline, override)
	end
	cust_ids = session.find(:id, "ctl00_MainArea_grdSearchResults_ctl00")['innerHTML'].scan(/C\d\d\d\d\d\d/)
	if(cust_ids.count > 0)
		number = cust_ids.count - 1
	else
		number = 0
	end
	session.find(:id, "ctl00_MainArea_grdSearchResults_ctl00__#{number}").click
	begin
		session.click_button("View")
	rescue Net::ReadTimeout
	end
end

def press_search(session, config, pipeline, override)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Search Customers page", "load"){
		if(pipeline)
			session.find(:id, "ctl00_MainArea_txtBusinessName_text").native.clear
			session.find(:id, "ctl00_MainArea_txtFirstName_text").native.clear
			session.find(:id, "ctl00_MainArea_txtLastName_text").native.clear
			session.find(:id, "ctl00_MainArea_txtPostCode_text").native.clear
			session.find(:id, "ctl00_MainArea_txtPhone_text").native.clear
			session.find(:id, "ctl00_MainArea_txtBusinessName_text").send_keys(config['business_name'])
			session.find(:id, "ctl00_MainArea_txtFirstName_text").send_keys(config['first_name'])
			session.find(:id, "ctl00_MainArea_txtLastName_text").send_keys(config['last_name'])
			session.find(:id, "ctl00_MainArea_txtPostCode_text").send_keys(config['postcode'])
			if(override == "")
				session.find(:id, "ctl00_MainArea_txtPhone_text").send_keys(config['landline'])
			else
				session.find(:id, "ctl00_MainArea_txtPhone_text").send_keys(override)
			end
			pipeline = false
		end
		session.find(:id, "ctl00_MainArea_btnSearch").click
		sleep(1) #just to ensure that javascript load starts before we look for it
	})
		raise "Could not press search"
	end
end

def confirm_customer(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times_customer_search', 'timeout_threshold_customer_search', "Customer's page", "Load"){
		begin
			session.within_frame(0) do
				doc = session.find(:id, "main-inner")['innerHTML']
				if (doc.scan("Customer Number").count > 0)
					puts "Customer page opened successfully!"
					return true
				elsif(doc.scan("Customer Number").count <= 0)
					raise "The Customer could not be successfully retrieved."
				end
			end
		rescue Capybara::ExpectationNotMet
			doc = session.find(:id, "main-inner")['innerHTML']
			if (doc.scan("Customer Number").count > 0)
				puts "Customer page opened successfully!"
				return true
			elsif(doc.scan("Customer Number").count <= 0)
				raise "The Customer could not be successfully retrieved."
			end
		end
	})
		return false
	end
end
