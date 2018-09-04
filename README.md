# Hub-Automated-Tests-Staged

Other Files:
config.yml - stores constants that are needed universally
Gemfile - contains a few require statements needed universally

Utility Files:
Mic-stage_Conduct_Sale.rb - contains all methods needed for Conduct_Sale.rb only
Mic-stage_Customer_Retrieval.rb - contains all methods needed to retrieve customer (used by {Check_Customer_Has_Email.rb, Conduct_Sale.rb, Create_New_Customer.rb, Customer_Retrieval.rb, Quote.rb, User_Info_Replace.rb})
Mic-stage_Login.rb - contains all methods for logging onto hub (used by all tests but Delete_Customer.rb)
Mic-stage_Quote.rb - contains all methods for quoting any of the products in hub
Product.rb - class for all products available in hub (also used to check that input corresponds to one) (used in quoting and conducting sale)
Selenium_Firefox.rb - used to set up driver for headless testing (no graphics card)
wait_for_page_to_load.rb - used to try running same bit of code a certain number of times, if it fails all of these, then send timeout error message

Test Files (in order of use):
Login.rb - opens Hub and logs in (plus checks can retrieve logo)
User_Info_Replace.rb - opens Hub and searches for first of list of available customers, if cannot find then sets this to data in config, else updates config to info for next customer in array
Customer_Retrieval.rb - opens Hub, goes to customer search screen and retrieves first customer that comes up (confirms if can find Customer Number string)
Create_New_Customer.rb - opens Hub and creates our customer using variables in config (if already exists, then opens their page)
Check_Customer_Has_Email.rb - opens our customer's page and checks that they have email in config.yml saved against them, if not then adds it
Quote.rb - opens Hub, goes to customer, goes through quote process for ehichever product input (as 3rd input argument)
Conduct_Sale.rb - opens customer page and runs through conduct sale for whichever product input (as 3rd input argument)
Delete_Customer.rb - uses SQL to move customer to customer.CustomerMaintenence table (so will be deleted at end of the day)