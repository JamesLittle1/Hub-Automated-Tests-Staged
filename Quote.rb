require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Quote.rb'
require './Product.rb'
require './wait_for_authentication_to_load.rb'
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
if(!quote_load(session, config))
	puts "Quote page failed to load"
	exit -1
end
if(!quote(session, config, ARGV[0], ARGV[1], prod)) # Add third argument for quote type e.g. electricity
	puts "Quote failed"
	exit -1
end
if(prod == Products.send(:electricity) || prod == Products.send(:gas))
	if(!get_prices(session, config))
		puts "Failed to get prices"
		exit -1
	end
	session.within_frame(0) do
		if(!confirm_quote(session, config, prod))
			puts "Failed to confirm quote"
			exit -1
		end
	end
else
	if(!confirm_quote(session, config, prod))
		puts "Failed to confirm quote"
		exit -1
	end
end
	# if(!send_quote_email(session, config))
		# puts "Failed to send quote email"
		# exit -1
	# end
# else
# if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Customer Screen", "load"){
	# session.click_button("Exit")
# })
	# puts "Failed to finish #{prod} quote"
# end
# if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Confirm quote", "complete"){
	# doc = ""
	# doc = session.find(:id, "ctl00_MainArea_ProductMatrix1_ucProductMatrix1_ProductMatrixTable")['innerHTML']
	# if(doc.scan(/#{prod}.*<\/td><td.*\n.*\n.*background-color:#3030FF/).count > 0)
		# puts "Successfully quoted #{prod}!"
	# else
		# puts "#{prod} quote not showing up!"
		# exit -1
	# end
# })
	# puts "Failed to confirm #{prod} quote"
	# return false
# end
# end
