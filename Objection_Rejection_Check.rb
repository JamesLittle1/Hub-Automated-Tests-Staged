#Inputs: USERNAME, PASSWORD, objections/rejections, unresolved/new
require 'capybara'
require 'yaml'
require './Selenium_Firefox.rb'
require './Mic-stage_Login.rb'
require './wait_for_page_to_load.rb'
require './Mic-stage_Objections_Rejections.rb'

config = YAML.load_file("./config.yml")

session = Capybara::Session.new :selenium_firefox
if(!login(session, config, ARGV[0], ARGV[1], true))
	puts "Failed to log onto Hub"
	exit -1
end
if(!search_objections_rejections(session, config, CheckType.send(ARGV[2].to_sym), CheckType.send(ARGV[3].to_sym)))
	puts "Failed to successfully complete search_unresolved_objections."
	exit -1
end