require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Quote.rb'
require './Mic-stage_Conduct_Sale.rb'
config = YAML.load_file("./config.yml")

session = Capybara::Session.new :selenium_firefox
login(session, ARGV[0], ARGV[1])

if(!search_customers(session, config))
	puts "Search_customers failed"
	exit -1
end
if(!select_customer(session, config, true))
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
if(!finish(session, config))
	puts "Failed to pass Finish tab"
	exit -1
end
