require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './wait_for_page_to_load.rb'
config = YAML.load_file("./config.yml")

session = Capybara::Session.new :selenium_firefox

if(!open_search_customer_frame(session, config, ARGV[0], ARGV[1]))
	puts "Failed to log onto Hub"
	exit -1
end

if(!select_customer(session, config, false, true))
	puts "select_customer failed"
	exit -1
end
if(!confirm_customer(session, config))
	puts "select_customer failed"
	exit -1
end

puts "Successfully retrieved customer!"
