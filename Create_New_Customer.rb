require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './wait_for_authentication_to_load.rb'
config = YAML.load_file("./config.yml")

session = Capybara::Session.new :selenium_firefox

if(!login(session, config, ARGV[0], ARGV[1]))
	puts "Failed to log onto Hub"
	exit -1
end

if(!search_customers(session, config, ARGV[0], ARGV[1]))
	puts "Search_customers failed"
	exit -1
end

def open_new_customer_screen(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "New Customer page", "load"){
		session.within_frame(0) do
			session.click_button("New Opportunity")
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "New Customer popup", "load"){
		session.within_frame(0) do
			session.click_button("OK")
		end
	})
		return false
	end
	return true
end

def new_customer_screen(session, config)
	if(!wait_for_authentication_to_load(session, config, 'loop_times_customer_search', 'timeout_threshold_customer_search', "New Customer authentication", "load"){
		authenticate(session.driver.browser, ARGV[0], ARGV[1])
	})
		return false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "New Customer page", "load"){
		session.within_frame(0) do
			session.within_frame(0) do
				session.find(:id, "Salutation").send_keys("\ue015")
				session.find(:id, "FirstName").send_keys(config['first_name'])
				session.find(:id, "LastName").send_keys(config['last_name'])
				session.find(:id, "BusinessName").send_keys(config['business_name'])
				session.find(:id, "PostCode").send_keys(config['postcode'])
				session.find(:id, "IsCOT").send_keys("\ue015\ue015")
				session.find(:id, "Landline").send_keys(config['landline'])
				session.click_button("search-button")
			end
		end
	})
		return false
	end
	#Check that search has worked, else search again
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Search Check", "run"){
		session.within_frame(0) do
			session.within_frame(0) do
				if(session.find(:id, "qualificationContainer")['innerHTML'].scan("A value is required").count > 0)
					session.click_button("search-button")
				end
			end
		end
	})
		return false
	end
	
	# Figure out if we have to use existing user
	create_new = true
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Customer Search", "load"){
		session.within_frame(0) do
			session.within_frame(0) do
				if(session.find(:id, "business-results")['innerHTML'].scan("Perfect Match").count > 0)
					create_new = false
					break
				elsif(session.find(:id, "business-results")['innerHTML'].scan(Regexp.union(/Bronze/, /Silver/, /Gold/)).count > 0 || session.find(:id, "business-search-results")['innerHTML'].scan("No matches found").count > 0)
					break
				end
			end
		end
	})
		return false
	end
	if(create_new)
		return create_new_business(session, config)
	else
		return use_existing_business(session, config)
	end
end

def create_new_business(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "New Customer Search", "load"){
		session.within_frame(0) do
			session.within_frame(0) do
				session.click_button("create-business-button")
			end
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "New Business section", "load"){
		session.within_frame(0) do
			session.within_frame(0) do
				session.find(:id, "AddressLine1").send_keys(config['address_line_1'])
				session.find(:id, "City").send_keys(config['city'])
				session.find(:id, "County").send_keys(config['county'])
				session.find(:id, "BusinessType").send_keys("\ue015")
				session.click_button("qualify-button")
			end
		end
	})
		return false
	end
	if(!confirm_customer_quote_page(session, config))
		puts "Failed to confirm that landed on quote page after creating new customer"
		return false
	end
	return true
end

def use_existing_business(session, config)
	session.within_frame(0) do
		session.within_frame(0) do
			session.first('td', text: "Perfect Match").click
			session.click_button("use-existingbusiness-button")
		end
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Progress Open Opportunities", "load"){
		session.within_frame(0) do
			session.within_frame(0) do
				session.find(:id, "open-opportunity-results").find(:id, "0").click
				session.click_button("select-progress-button")
			end
		end
	})
		return false
	end
	if(!confirm_customer(session, config))
		puts "Could not confirm customer"
		return false
	end
	return true
end

# def if_quote_then_back(session, config)
	# ret = false
	# if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Customer page", "open"){
		# session.within_frame(0) do
			# sleep(4) #Sleep so that page loads before we search
			# if(session.html.scan("Please select the first premises the customer wants to quote against").count > 0)
				# ret = true
			# end
		# end
	# })
		# return false
	# end
	# if(ret)
		# if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold'){
			# session.within_frame(0) do
				# session.find(:id, "ctl00_MainArea_wzrdQuoting_StartNavigationTemplateContainerID_btnCancel").click
			# end
		# })
			# return false
		# end
	# end
	# return true
# end

def confirm_customer_quote_page(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Quote page", "load"){
		session.within_frame(0) do
			doc = session.find(:id, "ctl00_MainArea_lblOppId")['innerHTML']
			if(doc.scan(/#{config['FirstName']}.*#{config['LastName']}/).count > 0)
				puts "Successfully landed on Quote page after Creating New Customer"
			else
				puts "Failed to confirm that landed on Quote page after attempting to Create New Customer"
			end
		end
	})
		return false
	end
	return true
end

if(!open_new_customer_screen(session, config))
	puts "open_new_customer_screen failed"
	exit -1
end
if(!new_customer_screen(session, config))
	puts "new_customer_screen failed"
	exit -1
end 
# if(!if_quote_then_back(session, config))
	# puts "if_quote_then_back failed"
	# exit -1
# end 
# if(!confirm_customer(session, config))
	# puts "Could not confirm customer"
	# exit -1
# end
