#Inputs: USERNAME, PASSWORD, objections/rejections, unresolved/new
require 'capybara'
require 'yaml'
require './Selenium_Firefox.rb'
require './Mic-stage_Login.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Objections_Rejections.rb'

config = YAML.load_file("./config.yml")

session = Capybara::Session.new :selenium_firefox
session1 = Capybara::Session.new :selenium_firefox
session2 = Capybara::Session.new :selenium_firefox
session3 = Capybara::Session.new :selenium_firefox

type1 = Type1.send(ARGV[2].to_sym)
type2 = Type2.send(ARGV[3].to_sym)
ret = {"Total" => 0, "DIFY" => 0, "SME" => 0, "MB" => 0}
if(!Type1.checking_objections_rejections(type1))
	puts "Input 3 not an objection or rejection"
	exit -1
end
if(!Type2.checking_new_unresolved(type2))
	puts "Input 4 not new or unresolved"
	exit -1
end

# Running each search at the same time as its own thread
total = Thread.new{
	if(!login(session, config, ARGV[0], ARGV[1]))
		puts "Failed to log onto Hub"
		exit -1
	end
	if(!search_objections_rejections(session, config, type1, type2, Type3.send(:total), ret))
		puts "Failed to successfully complete search_unresolved_objections."
		exit -1
	end
	session.driver.quit
}
dify = Thread.new{
	if(!login(session1, config, ARGV[0], ARGV[1]))
		puts "Failed to log onto Hub"
		exit -1
	end
	if(!search_objections_rejections(session1, config, type1, type2, Type3.send(:dify), ret))
		puts "Failed to successfully complete search_unresolved_objections."
		exit -1
	end
	session1.driver.quit
}
sme = Thread.new{
	if(!login(session2, config, ARGV[0], ARGV[1]))
		puts "Failed to log onto Hub"
		exit -1
	end
	if(!search_objections_rejections(session2, config, type1, type2, Type3.send(:sme), ret))
		puts "Failed to successfully complete search_unresolved_objections."
		exit -1
	end
	session2.driver.quit
}
mb = Thread.new{
	if(!login(session3, config, ARGV[0], ARGV[1]))
		puts "Failed to log onto Hub"
		exit -1
	end
	if(!search_objections_rejections(session3, config, type1, type2, Type3.send(:mb), ret))
		puts "Failed to successfully complete search_unresolved_objections."
		exit -1
	end
	session.driver.quit
}

# Check each thread is complete before continuing
total.join
dify.join
sme.join
mb.join

if(ret["Total"] == (ret["DIFY"] + ret["SME"] + ret["MB"]))
	puts "Test passed! Total Unresolved Objections = DIFY + SME + MB"
	puts "#{ret["Total"]} == #{ret["DIFY"]} + #{ret["SME"]} + #{ret["MB"]}"
	exit 0
else
	puts "Test Failed!"
	puts "#{ret["Total"]} != #{ret["DIFY"]} + #{ret["SME"]} + #{ret["MB"]}"
	exit -1
end