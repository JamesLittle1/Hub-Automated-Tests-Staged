require 'capybara'
require 'yaml'
require './Mic-stage_Login.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './Selenium_Firefox.rb'
config = YAML.load_file("./config.yml")

session = Capybara::Session.new :selenium_firefox


login(session, config, ARGV[0], ARGV[1])

if(!search_customers(session, config))
	puts "Search_customers failed"
	exit -1
end

if(!select_customer(session, config, true))
	puts "Search_customers failed"
	exit -1
end

def check_customer_has_email(session, config)
	no_email = false
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "check_customer_has_email", "run"){
		session.within_frame(0) do
			session.find(:id, "ctl00_MainArea_ProspectPageMailInfo1_cmbEmail_Input").click
			if(session.find(:id, "ctl00_MainArea_ProspectPageMailInfo1_cmbEmail_DropDown")['innerHTML'].scan(config['email']).count == 0)
				no_email = true
			end
		end
	})
		return false
	end
	if(no_email)
		session.within_frame(0) do
			session.find(:id, "ctl00_MainArea_ProspectPageMailInfo1_imgContactEdit").click
		end
		return fill_in_email(session, config)
	else
		puts "Customer already has email!"
		return true
	end
end

def fill_in_email(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Edit Contact Information", "load"){
		session.within_frame(0) do
			begin
				session.click_button("ctl00_MainArea_ucMntCustomerContact_btnAddEmails")
			rescue Capybara::ElementNotFound => e
				session.find(:xpath, "/html/body/form/div[5]/div/div[2]/div/div[2]/div[1]/div[3]/div[2]/div[1]").click
				session.click_button("ctl00_MainArea_ucMntCustomerContact_btnAddEmails")
			end
			session.find(:id, "ctl00_MainArea_ucMntCustomerContact_rptEmails_ctl01_ucMntEmail_txtEmailAddress_text").send_keys(config['email'])
			session.click_button("ctl00_MainArea_ucMntCustomerContact_btnSave")
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Email", "save"){
		session.within_frame(0) do
			session.click_button("ctl00_MainArea_ucMntCustomerContact_btnClose")
		end
	})
		return false
	end
	puts "Customer's email successfully added"
	return true
end

if(!check_customer_has_email(session, config))
	puts "Check_Customer_Has_Email failed"
	exit -1
end
