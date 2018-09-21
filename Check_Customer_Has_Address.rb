require 'capybara'
require 'yaml'
require './Mic-stage_Login.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './Selenium_Firefox.rb'
config = YAML.load_file("./config.yml")

session = Capybara::Session.new :selenium_firefox

if(!open_search_customer_frame(session, config, ARGV[0], ARGV[1]))
	puts "Open_search_customer_frame failed"
	exit -1
end

if(!select_customer(session, config, true, true))
	puts "Search_customers failed"
	exit -1
end

def check_customer_has_address(session, config)
	address_added = [false]
	while(!address_added[0])
		if(!check(session, config))
			puts "Adding customer's home address"
			# Trying to add address that's already there first
			address_added[0] = add_address(session, config)
			puts "address_added[0] = #{address_added[0]}"
		else
			puts "Customer already has home address"
			return true
		end
	end
	if(check(session, config))
		puts "Customer's Home address was added correctly"
		return true
	else
		puts "Customer's Home address wasn't added"
		return false
	end
end

def add_address(session, config)
	session.find(:id, "ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_cmbAddresses_Input").click
	dropdown = session.find(:id, "ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_cmbAddresses_DropDown")['innerHTML']
	if(dropdown.scan(/<li/).count > 1)
		puts "Adding address officially"
		if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "New Address added to dropdown", "select"){
			session.find(:id, "ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_cmbAddresses_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_cmbAddresses_Input").send_keys("\ue006")
			session.click_button("ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_btnAddAddresses")
		})
			raise "Error running Add_Address"
		end
		sleep(1)
		while (session.html.scan(/ctl00_MainArea_RadAjaxLoadingPanel1ctl00_MainArea_RadAjaxPanel1/).count > 0)
			#Waiting for page to load
		end
		if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "New Address Move-in Date", "fill in"){
			session.find(:id, "ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_rptAddresses_ctl02_ucMntAddress_dpMoveInDate_popupButton").click
			session.find(:id, "ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_rptAddresses_ctl02_ucMntAddress_dpMoveInDate_calendar_Title").click
			session.find(:id, "rcMView_PrevY").click
			session.find(:id, "rcMView_2012").click
			session.find(:id, "rcMView_OK").click
			session.find(:id, "ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_rptAddresses_ctl02_ucMntAddress_dpMoveInDate_calendar_Top").click_link("10")
			session.click_button("Save")
			session.click_button("Exit")
		})
			raise "Error running Add_Address"
		end
		return true
	else
		# If not then fill in new address
		puts "Filling in new address"
		if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Address Search", "load"){
			session.click_button("ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_btnAddAddresses")
			session.find(:id, "ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_ucAddressGBSearch_txtPostCode_text").native.clear
			session.find(:id, "ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_ucAddressGBSearch_txtPostCode_text").send_keys("SM4 5BE")
			session.click_button("ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_ucAddressGBSearch_btnSearchPostCode")
		})
			raise "Error running Add_Address"
		end
		sleep(1)
		while (session.html.scan(/ctl00_MainArea_RadAjaxLoadingPanel1ctl00_MainArea_RadAjaxPanel1/).count > 0)
			#Waiting for page to load
		end
		if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Address Checkbox", "click"){
			session.check("ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_ucAddressGBSearch_grdSearchResults_ctl00_ctl22_ClientSelectColumnSelectCheckBox")
			session.click_button("ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_ucAddressGBSearch_btnUseSelected")
		})
			raise "Error running Add_Address"
		end
		sleep(1)
		while (session.html.scan(/ctl00_MainArea_RadAjaxLoadingPanel1ctl00_MainArea_RadAjaxPanel1/).count > 0)
			#Waiting for page to load
		end
		if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "New Address", "save"){
			session.click_button("ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_ucAddressGBSearch_btnSaveAddressDetailsUC")
			session.click_button("ctl00_MainArea_ucMntCustomerContact_btnSave")
			session.click_button("ctl00_MainArea_ucMntCustomerContact_btnClose")
		})
			raise "Error running Add_Address"
		end
		return false
	end
end

def check(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Customer Address check", "run"){
		session.find(:id, "ctl00_MainArea_ProspectPageMailInfo1_imgContactEdit").click
		if(!session.has_css?("#ctl00_MainArea_ucMntCustomerContact_ucMntContactAddresses_btnAddAddresses"))
			session.find("#ctl00_MainArea_ucMntCustomerContact_pnlAddresses > div:nth-child(1)").click # <- Problem code
		end
		session.find(:id, "ctl00_MainArea_ucMntCustomerContact-inner-1")
	})
		raise "check failed to run successfully"
	end
	doc = session.find(:id, "ctl00_MainArea_ucMntCustomerContact-inner-1")['innerHTML']
	return (doc.scan(/value=\"Home\"/).count > 0)
end

if(!check_customer_has_address(session, config))
	puts "check_customer_has_address failed to run correctly"
	exit -1
end