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

def check_customer_has_email(session, config)
	no_email = [false]
	if(!check(session, config, no_email))
		return false
	end
	if(no_email[0])
		session.find(:id, "ctl00_MainArea_ProspectPageMailInfo1_imgContactEdit").click
		return fill_in_email(session, config)
	else
		puts "Customer already has email!"
		return true
	end
end

def fill_in_email(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Edit Contact Information", "load"){
		begin
			session.click_button("ctl00_MainArea_ucMntCustomerContact_btnAddEmails")
		rescue Capybara::ElementNotFound => e
			session.find(:xpath, "/html/body/form/div[5]/div/div[2]/div/div[2]/div[1]/div[3]/div[2]/div[1]").click
			session.click_button("ctl00_MainArea_ucMntCustomerContact_btnAddEmails")
		end
		session.find(:id, "ctl00_MainArea_ucMntCustomerContact_rptEmails_ctl01_ucMntEmail_txtEmailAddress_text").send_keys(config['email'])
		session.click_button("ctl00_MainArea_ucMntCustomerContact_btnSave")
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Email", "save"){
		session.click_button("ctl00_MainArea_ucMntCustomerContact_btnClose")
	})
		return false
	end
	no_email = [false]
	if(!check(session, config, no_email))
		return false
	end
	if(no_email[0])
		puts "Error: Customer still has no email"
	else
		puts "Customer has email now!"
	end
	puts "Customer's email successfully added"
	return true
end

def check(session, config, no_email)
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "check_customer_has_email", "run"){
		session.find(:id, "ctl00_MainArea_ProspectPageMailInfo1_cmbEmail_Input").click
		if(session.find(:id, "ctl00_MainArea_ProspectPageMailInfo1_cmbEmail_DropDown")['innerHTML'].scan(config['email']).count == 0)
			no_email[0] = true
		end
	})
		return false
	end
	return true
end

if(!check_customer_has_email(session, config))
	puts "Check_Customer_Has_Email failed"
	exit -1
end
