require 'selenium-webdriver'
Capybara.register_driver :selenium_firefox do |app|
  options = Selenium::WebDriver::Firefox::Options.new
  options.add_argument('--ignore-certificate-errors')
  options.add_argument('--allow-insecure-localhost')
  options.add_argument('--disable-popup-blocking')
  options.add_argument('--disable-translate')
  options.add_argument('--disable-gpu')
  options.add_argument('--headless')
  
  Capybara::Selenium::Driver.new(@app,
    browser: :firefox,
    options: options
  )
end