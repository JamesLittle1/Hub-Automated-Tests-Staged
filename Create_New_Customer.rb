require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Customer_Retrieval.rb'
config = YAML.load_file("./config.yml")

session = Capybara::Session.new :selenium_firefox

login(session, ARGV[0], ARGV[1])

if(!search_customers(session, config))
	puts "Search_customers failed"
	exit -1
end

#Create New Customer Here
def open_new_customer_screen(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "New Customer page", "load"){
		session.within_frame(0) do
			session.click_button("New Opportunity")
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "New Customer popup", "load"){
		session.within_frame(0) do
			session.click_button("OK")
		end
	})
		return false
	end
	return true
end

def new_customer_screen(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "New Customer authentication", "load"){
		authenticate(session.driver.browser)
	})
		return false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "New Customer page", "load"){
		session.within_frame(0) do
			session.within_frame(0) do
				session.find(:id, "Salutation").send_keys("\ue015")
				session.find(:id, "FirstName").send_keys(config['first_name'])
				session.find(:id, "LastName").send_keys(config['last_name'])
				session.find(:id, "BusinessName").send_keys(config['business_name'])
				session.find(:id, "PostCode").send_keys(config['postcode'])
				session.find(:id, "IsCOT").send_keys("\ue015\ue015")
				session.find(:id, "Landline").send_keys("07878787878")
				session.click_button("search-button")
			end
		end
	})
		return false
	end
	#Check that search has worked, else search again
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Search Check", "run"){
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
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "New Customer Search", "load"){
		session.within_frame(0) do
			session.within_frame(0) do
				session.click_button("create-business-button")
			end
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "New Business section", "load"){
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
	return true
end

def use_existing_business(session, config)
	session.within_frame(0) do
		session.within_frame(0) do
			session.first('td', text: "Perfect Match").click
			session.click_button("Use Existing Business")
		end
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Progress Open Opportunities", "load"){
		session.within_frame(0) do
			session.within_frame(0) do
				session.find(:id, "open-opportunity-results").find(:id, "0").click
				session.click_button("select-progress-button")
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

puts "Press enter to continue"
gets
