require 'tiny_tds'

client = TinyTds::Client.new(:dataserver => ENV['DATASERVER_STAGED'], :database => ENV['DATABASE_STAGED'], :username => ENV['USERNAME_SQL'], :password => ENV['PASSWORD_SQL'])
result = client.execute('SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON 
SET NUMERIC_ROUNDABORT OFF
exec [customer].[CustomerAutoRemove]')
puts "customer should now be deleted"