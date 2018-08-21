require 'capybara'
require './Mic-stage_Login.rb'

require './Selenium_Firefox.rb'

session = Capybara::Session.new :selenium_firefox

login(session, ARGV[0], ARGV[1])
session.driver.quit
