require 'capybara'
require 'yaml'
config = YAML.load_file("./config.yml")
require './Mic-stage_Login.rb'
require './Selenium_Firefox.rb'

session = Capybara::Session.new :selenium_firefox

if(!login(session, config, ARGV[0], ARGV[1]))
	puts "Failed to log onto Hub"
	exit -1
end
session.driver.quit
