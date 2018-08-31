require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Quote.rb'
require './Mic-stage_Conduct_Sale.rb'
require './Product'
config = YAML.load_file("./config.yml")

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
if(!select_quote(session, config, ARGV[2]))
	puts "Failed pass Sale Quote tab"
	exit -1
end
if(!confirm_quote(session, config, ARGV[0], ARGV[1]))
	puts "Failed to pass Confirm Quote tab"
	exit -1
end
if(!additional_data(session, config))
	puts "Failed to pass Additional Data tab"
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
if(ARGV[2] == Product::Electricity || ARGV[2] == Product::Gas)
	if(!finish(session, config))
		puts "Failed to pass Finish tab"
		exit -1
	end
else
	session.find(:id, "ctl00_MainArea_wzrdConductSale_FinishNavigationTemplateContainerID_btnClose").click
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Sale", "confirm"){
		doc = session.find(:id, "ctl00_MainArea_ProductMatrix1_ucProductMatrix1_ProductMatrixTable")['innerHTML']
		if(doc.scan(/#{ARGV[2][9..-1]}.*<\/td><td.*\n.*\n.*background-color:#FFCC00/).count > 0 || doc.scan(/#{ARGV[2][9..-1]}.*<\/td><td.*\n.*\n.*background-color:#33FF00/).count > 0)
			puts "Successfully quoted #{ARGV[2][9..-1]}!"
		else
			puts "#{ARGV[2][9..-1]} quote not showing up!"
			exit -1
		end
	})
		return false
	end
end
