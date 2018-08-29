# Method to search for all customers
def search_customers(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Homepage", "load"){
		session.click_link("Search")
		session.click_link("All Customers")
	})
		return false
	end
	return true
end

def select_customer(session, config, pipeline=false, override="")
	if(override == "")
		loop_times = 'loop_times_customer_search'
		timeout_threshold = 'timeout_threshold_customer_search'
	else
		loop_times = 'loop_times_override'
		timeout_threshold = 'timeout_threshold_override'
	end
	
	session.within_frame(0) do
		press_search(session, config, pipeline, override)
	end
	
	if(!wait_for_page_to_load(session, config, loop_times, timeout_threshold, "Search Customers results", "load"){
		session.within_frame(0) do
			if(session.has_css?("html body#main div#ctl00_MainArea_RadAjaxLoadingPanel1ctl00_MainArea_grdSearchResults.RadAjax.RadAjax_Default"))
				raise "page is still loading"
			end
			if(session.find(:id, "ctl00_MainArea_grdSearchResults_ctl00")['innerHTML'].scan("There are no items to display.").count > 0)
				puts "No items returned from search - try again"
				press_search(session, config, pipeline, override)
			end
			#session.find(:xpath, "//tr[@id='ctl00_MainArea_grdSearchResults_ctl00__0']/td[6]").click
			session.find(:id, "ctl00_MainArea_grdSearchResults_ctl00__0").click
			session.find(:id, "ctl00_MainArea_btnEdit").click
		end
	})
		return false
	end
	return true
end

def press_search(session, config, pipeline, override)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Search Customers page", "load"){
		#session.within_frame(0) do # switches to the frame just loaded up - so we can use search features
			if(pipeline)
				session.find(:id, "ctl00_MainArea_txtBusinessName_text").native.clear
				session.find(:id, "ctl00_MainArea_txtFirstName_text").native.clear
				session.find(:id, "ctl00_MainArea_txtLastName_text").native.clear
				session.find(:id, "ctl00_MainArea_txtPostCode_text").native.clear
				if(override == "")
					session.find(:id, "ctl00_MainArea_txtBusinessName_text").send_keys(config['business_name'])
					session.find(:id, "ctl00_MainArea_txtFirstName_text").send_keys(config['first_name'])
					session.find(:id, "ctl00_MainArea_txtLastName_text").send_keys(config['last_name'])
					session.find(:id, "ctl00_MainArea_txtPostCode_text").send_keys(config['postcode'])
				else
					session.find(:id, "ctl00_MainArea_txtBusinessName_text").send_keys(override)
					session.find(:id, "ctl00_MainArea_txtFirstName_text").send_keys(override)
					session.find(:id, "ctl00_MainArea_txtLastName_text").send_keys(override)
				end
				pipeline = false
			end
			session.find(:id, "ctl00_MainArea_btnSearch").click
			sleep(1) #just to ensure that javascript load starts before we look for it
		#end
	})
		return false
	end
end

def confirm_customer(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times_customer_search', 'timeout_threshold_customer_search', "Customer's page", "Load"){
		session.within_frame(0) do
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
