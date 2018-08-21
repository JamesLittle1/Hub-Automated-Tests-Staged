require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Quote.rb'
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
if(!quote_load(session, config))
	puts "Quote page failed to load"
	exit -1
end
if(!quote(session, config))
	puts "Quote failed"
	exit -1
end
if(!get_prices(session, config))
	puts "Failed to get prices"
	exit -1
end
if(!send_quote_email(session, config))
	puts "Failed to send quote email"
	exit -1
end

puts "press enter to exit"
gets
