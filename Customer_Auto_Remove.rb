require 'tiny_tds'

client = TinyTds::Client.new(:dataserver => ENV['DATASERVER_STAGED'], :database => ENV['DATABASE_STAGED'], :username => ENV['USERNAME_SQL'], :password => ENV['PASSWORD_SQL'], :timeout => 90000)
sql = 'SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON; SET NUMERIC_ROUNDABORT OFF; exec [customer].[CustomerAutoRemove];'
result = client.execute(sql)
result.do
puts "customer should now be deleted"
