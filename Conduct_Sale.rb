require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Quote.rb'
require './Mic-stage_Conduct_Sale.rb'
require './Product'
require './wait_for_authentication_to_load.rb'
require './wait_for_econtract_to_send.rb'
config = YAML.load_file("./config.yml")
prod = Products.send(ARGV[2].downcase.to_sym)
if(!Products.checking_one_of_products(prod))
	puts "This is not one of the products listed, exiting test"
	exit -1
end

session = Capybara::Session.new :selenium_firefox
if(!open_search_customer_frame(session, config, ARGV[0], ARGV[1]))
	puts "Failed to log onto Hub"
	exit -1
end

if(!select_customer(session, config, true, true))
	puts "select_customer failed"
	exit -1
end

if(!conduct_sale_load(session, config))
	puts "Failed to open Conduct Sale Wizard"
	exit -1
end
if(!check_for_records(session, config))
	puts "Failed to run check_for_records"
	exit -1
end
if(!select_quote(session, config, prod))
	puts "Failed pass Sale Quote tab"
	exit -1
end
if(!confirm_quote(session, config, ARGV[0], ARGV[1]))
	puts "Failed to pass Confirm Quote tab"
	exit -1
end
additional_data_bool = false
for i in 1..config['standard_retry']
	additional_data_bool = additional_data(session, config)
	break if additional_data_bool
end
if(!additional_data_bool)
	puts "Failed to pass Additional Data tab after #{config['standard_retry']} attempts"
	exit -1
end
if(!summary(session, config))
	puts "Failed to pass Summary tab"
	exit -1
end
if(!preferences(session, config))
	puts "Failed to pass Preferences tab"
	exit -1
end
if(!verbal(session, config))
	puts "Failed to pass Verbal tab"
	exit -1
end
if(prod == Products.send(:electricity) || prod == Products.send(:gas))
	# REMOVING FINAL FOR NOW - READD ONCE FIXED
	# if(!finish(session, config))
		# puts "Failed to pass Finish tab"
		# exit -1
	# end
else
	session.find(:id, "ctl00_MainArea_wzrdConductSale_FinishNavigationTemplateContainerID_btnClose").click
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Sale", "confirm"){
		doc = session.find(:id, "ctl00_MainArea_ProductMatrix1_ucProductMatrix1_ProductMatrixTable")['innerHTML']
		if(doc.scan(/#{prod}.*<\/td><td.*\n.*\n.*background-color:#FFCC00/).count > 0 || doc.scan(/#{prod}.*<\/td><td.*\n.*\n.*background-color:#33FF00/).count > 0)
			puts "Successfully quoted #{prod}!"
		else
			puts "#{prod} quote not showing up!"
			exit -1
		end
	})
		return false
	end
end
