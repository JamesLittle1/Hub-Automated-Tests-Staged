require 'capybara'
require './Selenium_Firefox.rb'
require 'yaml'
require './Mic-stage_Login.rb'
require './Mic-stage_Customer_Retrieval.rb'
require './wait_for_page_to_load.rb'
file_name = "./config.yml"
config = YAML.load_file(file_name)

count = true

session = Capybara::Session.new :selenium_firefox

if(!login(session, config, ARGV[0], ARGV[1]))
	puts "Failed to log onto Hub"
	exit -1
end
if(!search_customers(session, config, ARGV[0], ARGV[1]))
	puts "Search_customers failed"
	exit -1
end
if(!select_customer(session, config, true, false, "02087878787"))
	puts "No First customer, starting from the beginning again!"
	count = false
end

# array = ["\"First\"", "\"Second\"", "\"Third\"", "\"Fourth\"", "\"Fifth\"", "\"Sixth\"", "\"Seventh\"", "\"Eighth\"", "\"Ninth\"", "\"Tenth\"",
# "\"BB\"", "\"CC\"", "\"DD\"", "\"EE\"", "\"FF\"", "\"HH\"", "\"II\"", "\"JJ\"", "\"KK\"", "\"LL\"", "\"MM\"", "\"NN\"", "\"OO\"", "\"PP\"",
# "\"QQ\"", "\"RR\"", "\"SS\"", "\"TT\"", "\"UU\"", "\"VV\"", "\"WW\"", "\"XX\"", "\"YY\"", "\"ZZ\""]
array = ["\"02087878787\"", "\"02087878788\"", "\"02087878789\"", "\"02087878790\"", "\"02087878791\"", "\"02087878792\"", "\"02087878793\"", 
"\"02087878794\"", "\"02087878795\"", "\"02087878796\"", "\"02087878797\"", "\"02087878798\"", "\"02087878799\"", "\"02087878800\"", "\"02087878801\"", 
"\"02087878802\"", "\"02087878803\"", "\"02087878804\"", "\"02087878805\"", "\"02087878806\""]
yaml_content = File.read(file_name)
current = yaml_content.scan(/landline: \".*\"/)[0][10..-1]
if(count)
	i = array.index(current)
	new_content = yaml_content.gsub(current, array[array.index(current) + 1]) # will raise an error if runs out of options
	puts "Replacing " + current + " in config.yml With " + array[array.index(current) + 1]
else
	new_content = yaml_content.gsub(current, array[0])
	puts "Replacing " + current + " in config.yml With " + array[0]
end


puts "\n\n Old file: \n" + yaml_content
puts "\n New file: \n" + new_content
if (new_content != "")
	File.open(file_name, 'w') { |file| file.write(new_content) }
end
