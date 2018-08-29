require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Quote.rb'
require './Product.rb'
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
if(!quote(session, config, ARGV[0], ARGV[1], ARGV[2])) # Add third argument for quote type e.g. Product::Electricity
	puts "Quote failed"
	exit -1
end
if(ARGV[2] == Product::Electricity || ARGV[2] == Product::Gas)
	if(!get_prices(session, config))
		puts "Failed to get prices"
		exit -1
	end
	if(!send_quote_email(session, config))
		puts "Failed to send quote email"
		exit -1
	end
else
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Customer Screen", "load"){
		session.within_frame(0) do
			session.click_button("Exit")
		end
	})
		puts "Failed to finish #{ARGV[2][9..-1]} quote"
	end
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Confirm quote", "complete"){
		doc = ""
		session.within_frame(0) do
			doc = session.find(:id, "ctl00_MainArea_ProductMatrix1_ucProductMatrix1_ProductMatrixTable")['innerHTML']
			if(doc.scan(/#{ARGV[2][9..-1]}.*<\/td><td.*\n.*\n.*background-color:#3030FF/).count > 0)
				puts "Successfully quoted #{ARGV[2][9..-1]}!"
			else
				puts "#{ARGV[2][9..-1]} quote not showing up!"
				exit -1
			end
		end
	})
		puts "Failed to confirm #{ARGV[2][9..-1]} quote"
		return false
	end
end
