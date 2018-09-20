require 'tiny_tds'
require 'yaml'
config = YAML.load_file("./config.yml")
require 'terminal-table'

# Finding all customers to work with
client = TinyTds::Client.new(:dataserver => ENV['DATASERVER_STAGED'], :database => ENV['DATABASE_STAGED'], :username => ENV['USERNAME_SQL'], :password => ENV['PASSWORD_SQL'])
cust_ids = client.execute("SELECT CC.CustId FROM address.CustomerContact CC
  JOIN customer.Business B ON CC.CustId = B.CustId 
  WHERE FirstName = '#{config['first_name']}' AND LastName = '#{config['last_name']}' AND BusinessName = '#{config['business_name']}'")

# Deleting first in case already exist in table
cust_ids.each do |cust_id|
	sql = "DELETE FROM customer.CustomerMaintenance WHERE CustId IN (#{cust_id["CustId"]})"
	client = TinyTds::Client.new(:dataserver => ENV['DATASERVER_STAGED'], :database => ENV['DATABASE_STAGED'], :username => ENV['USERNAME_SQL'], :password => ENV['PASSWORD_SQL'])
	result = client.execute(sql)
end

# Inserting into table for deletion
cust_ids.each do |cust_id|
	sql1 = "INSERT INTO customer.CustomerMaintenance VALUES ((#{cust_id["CustId"]}),GETDATE(), NULL, 0, NULL)"
	client = TinyTds::Client.new(:dataserver => ENV['DATASERVER_STAGED'], :database => ENV['DATABASE_STAGED'], :username => ENV['USERNAME_SQL'], :password => ENV['PASSWORD_SQL'])
	result = client.execute(sql1)
end

# Returning to console screen the rows added to customer.CustomerMaintenance
sql2 = "SELECT * FROM [Hub_Staging_Live2].[customer].[CustomerMaintenance] 
WHERE CustId IN (  SELECT CC.CustId FROM address.CustomerContact CC
  JOIN customer.Business B ON CC.CustId = B.CustId 
  WHERE FirstName = '#{config['first_name']}' AND LastName = '#{config['last_name']}' AND BusinessName = '#{config['business_name']}')"
client = TinyTds::Client.new(:dataserver => ENV['DATASERVER_STAGED'], :database => ENV['DATABASE_STAGED'], :username => ENV['USERNAME_SQL'], :password => ENV['PASSWORD_SQL'])
result = client.execute(sql2)
results = result.each(:symbolize_keys => true, :as => :array, :cache_rows => true, :empty_sets => true) do |rowset| end
unless (results.nil? || results[0].nil?)
	table = Terminal::Table.new do |t|
		t << ["CustId", "InsertedDate", "RemovalDate", "RemovalFault", "FaultReason"]
		t << :separator
		results.each do |row|
			t << [row[0], row[1], row[2], row[3], row[4]]
		end
	end
	puts table
end
