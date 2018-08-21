require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './Mic-stage_Customer_Retrieval.rb'
file_name = "./config.yml"
config = YAML.load_file(file_name)

count = true

session = Capybara::Session.new :selenium_firefox

login(session, ARGV[0], ARGV[1])
if(!search_customers(session, config))
	puts "Search_customers failed"
	exit -1
end
if(!select_customer(session, config, "First"))
	puts "No First user, starting from the beginning again!"
	count = false
end

file_name = 'C:\Users\James.Little\Downloads\Capybara\Live\config.yml' # Don't need this as we have yaml_content
array = ["\"First\"", "\"Second\"", "\"Third\"", "\"Fourth\"", "\"Fifth\"", "\"Sixth\"", "\"Seventh\"", "\"Eighth\"", "\"Ninth\"", "\"Tenth\"",
"\"AA\"", "\"BB\"", "\"CC\"", "\"DD\"", "\"EE\"", "\"FF\"", "\"GG\"", "\"HH\"", "\"II\"", "\"JJ\"", "\"KK\"", "\"LL\""]
yaml_content = File.read(file_name)
current = yaml_content.scan(/first_name: \".*\"/)[0][12..-1]
if(count)
	i = array.index(current)
	new_content = yaml_content.gsub(current, array[array.index(current) + 1]) # will raise an error if runs out of options
	puts "Replacing " + current + " in config.yml With " + array[array.index(current) + 1]
	# puts "With " + array[array.index(current) + 1]
else
	new_content = yaml_content.gsub(current, array[0])
	puts "Replacing " + current + " in config.yml With " + array[0]
	# puts "With " + array[0]
end


puts "\n\n Old file: \n" + yaml_content
puts "\n New file: \n" + new_content
if (new_content != "")
	File.open(file_name, 'w') { |file| file.write(new_content) }
	#Replace old config file with new one here
end

#puts "Press enter to exit"
#gets

