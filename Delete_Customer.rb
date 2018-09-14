require 'tiny_tds'
require 'yaml'
config = YAML.load_file("./config.yml")
require 'terminal-table'

sql = "DELETE FROM customer.CustomerMaintenance WHERE CustId IN (SELECT CC.CustId FROM address.CustomerContact CC
  JOIN customer.Business B ON CC.CustId = B.CustId 
  WHERE FirstName = '#{config['first_name']}' AND LastName = '#{config['last_name']}' AND BusinessName = '#{config['business_name']}')"
client = TinyTds::Client.new(:dataserver => ENV['DATASERVER_STAGED'], :database => ENV['DATABASE_STAGED'], :username => ENV['USERNAME_SQL'], :password => ENV['PASSWORD_SQL'])
result = client.execute(sql)


sql1 = "INSERT INTO customer.CustomerMaintenance VALUES ((SELECT CC.CustId FROM address.CustomerContact CC
  JOIN customer.Business B ON CC.CustId = B.CustId 
  WHERE FirstName = '#{config['first_name']}' AND LastName = '#{config['last_name']}' AND BusinessName = '#{config['business_name']}'),
  GETDATE(), NULL, 0, NULL)"
client = TinyTds::Client.new(:dataserver => ENV['DATASERVER_STAGED'], :database => ENV['DATABASE_STAGED'], :username => ENV['USERNAME_SQL'], :password => ENV['PASSWORD_SQL'])
result = client.execute(sql1)

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
		t << [results[0][0], results[0][1], results[0][2], results[0][3], results[0][4]]
	end
	puts table
end

sql3 = "exec [customer].[CustomerAutoRemove]"
client = TinyTds::Client.new(:dataserver => ENV['DATASERVER_STAGED'], :database => ENV['DATABASE_STAGED'], :username => ENV['USERNAME_SQL'], :password => ENV['PASSWORD_SQL'])
client.execute('SET ANSI_NULLS ON')
client.execute('SET ANSI_PADDING ON')
client.execute('SET ANSI_WARNINGS ON')
client.execute('SET ARITHABORT ON')
client.execute('SET CONCAT_NULL_YIELDS_NULL ON')
client.execute('SET NUMERIC_ROUNDABORT OFF')
client.execute('SET QUOTED_IDENTIFIER ON')
result = client.execute(sql3)
