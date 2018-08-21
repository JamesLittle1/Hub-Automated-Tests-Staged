def quote_load(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Quote page", "load"){
		session.within_frame(0) do
			session.find(:id, "ctl00_MainArea_repActionControls_ctl01_lbPageAction").click
		end
	})
		return false
	end
	return true
end

def quote(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Quote", "process"){
		session.within_frame(0) do
			begin
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBusiness_ctl00_rptPremises_ctl00_ucQuotingPremises_imbPremisesSelect").click
			rescue
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBusiness_ctl00_lblBusinessName").click
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBusiness_ctl00_rptPremises_ctl00_ucQuotingPremises_imbPremisesSelect").click
			end
			session.find(:id, "ctl00_MainArea_wzrdQuoting_ucCompanyCreditScore_txtCreditScore_text").native.clear
			session.find(:id, "ctl00_MainArea_wzrdQuoting_ucCompanyCreditScore_txtCreditScore_text").send_keys("0")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_StartNavigationTemplateContainerID_StepNextButton").click
		end
	})
		return false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Quote page", "load"){
		puts "create_new = false"
		create_new = [false]
		searching = true
		while(searching) do
			puts "create_new = #{create_new}"
			searching = search_for_electricity_meter(session, config, create_new)
		end
	})
		return false
	end
	
	# load_attempts = 0
	# for i in 0..config['loop_times'] # First argument is the loop_times
		# sleep(config['timeout_threshold']) # Second argument is the timeout_threshold
		# begin
			# puts "create_new = false"
			# create_new = [false]
			# searching = true
			# while(searching) do
				# puts "create_new = #{create_new}"
				# searching = search_for_electricity_meter(session, config, create_new)
			# end
			# puts "Waited #{i + 1} second(s) for Quote page to load."
			# break
		# rescue => e
			# puts e.traceback
			# load_attempts += 1
			# if(load_attempts > (config['loop_times'] - 1)) # First argument is loop_times
				# puts("Quote page failed to load within #{config['timeout_threshold']*config['loop_times']} seconds.") #1st & 2nd
				# return false
			# end
			# next
		# end
	# end
	
	# Next tab
	# load_attempts = 0
	# for i in 0..config['loop_times']
		# sleep(config['timeout_threshold'])
		# begin
			# puts "create_new = false"
			# create_new = false
			# searching = true
			# while(searching) do
				# puts "Loop"
				# searching = search_for_electricity_meter(session, config, create_new)
			# end
			# puts "Waited #{i + 1} second(s) for Quote page to load."
			# break
		# rescue
			# #if entry doesn't exist try creating new one - make new method containing above block & commented out in if statement
			# puts "Rescued"
			# load_attempts += 1
			# # give a second chance
			# if (load_attempts > (config['timeout_threshold']*config['loop_times'] - 1))
				# puts("Quote page failed to load within #{config['timeout_threshold']*config['loop_times']} seconds.")
				# return false
			# end
			# create_new = true
			# puts "create_new = true"
			# load_attempts1 = 0
			# for j in 0..config['loop_times']
				# sleep(config['timeout_threshold'])
				# begin
					# search_for_electricity_meter(session, config, create_new)
					# puts "Waited #{j + 1} second(s) for Quote page to load."
					# break
				# rescue
					# load_attempts1 += 1
					# if(load_attempts1 > (config['timeout_threshold']*config['loop_times'] - 1))
						# puts("Quote page failed to load within #{config['timeout_threshold']*config['loop_times']} seconds.")
						# return false
					# end
					# next
				# end
			# end
			# next
		# end
	# end
	return true
end

def search_for_electricity_meter (session, config, create_new)
	# try clicking Get Prices first, then check for errors!
	session.within_frame(0) do
		#remove puts after testing
		puts "Entered search_for_electricity_meter"
		
		#--------------------------------------------exception for my created error - REMOVE FROM FINAL VERSION
		# remove_me = false
		
		if(create_new[0])
			#code here to go to search, change postcode, search, add electric meter, go back to electric
			session.click_link("Search")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_txtPostCode_text").native.clear
			session.find(:id, "ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_txtPostCode_text").send_keys("SM4 5BE")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_txtPremises_text").native.clear
			session.click_button("ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_btnSearch")
			#wait for it to load
			wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Quote page", "load"){
				session.find(:id, "ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_grdSearch_ctl00_ctl07_GECBtnExpandColumn").click
			}
			wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Quote page", "load"){
				session.click_button("ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_grdSearch_ctl00_ctl09_Detail20_ctl04_btnAddMPAN")
				#browser.switch_to.alert.accept() #would commenting this in avoid UnexpectedAlertOpenError?
			}
			#-------------------------------------------exception for my created error - REMOVE FROM FINAL VERSION
			# remove_me = true
			# if(remove_me)
				# wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "", ""){
					# if(session.html.scan("Object reference not set to an instance of an object").count > 0)
						# session.driver.go_back
					# elsif(session.all(:id, "ctl00_MainArea_wzrdQuoting_ucROPremises_cmbCoT_Input").count > 0)
						# create_new[0] = false
						# return true
					# end
				# }
			# end
		end
		if(session.find(:id, "ctl00_MainArea_wzrdQuoting_ucROPremises_cmbCoT_Input").value != "No")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_ucROPremises_cmbCoT_Input").send_keys("\ue015\ue015")
		end
		session.find(:id, "ctl00_MainArea_wzrdQuoting_ucROPremises_btnSaveCoT").click
		session.click_link("Electricity")
		
		#------------------------------------------------exception for my created error - REMOVE FROM FINAL VERSION
		# if(remove_me)
			# session.click_button("Add MPAN")
		# end
		
		#Checking that a meter exists
		puts "Checking if meter exists"
		if(session.find(:id, "ctl00_MainArea_wzrdQuoting_pnlElectric")['innerHTML'].scan("ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_pnlElecMeter").count ==0)
			puts "Create new"
			create_new[0] = true
			return true
		end
		
		#Checking that the meter is quotable - else need to change database
		doc = session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_pnlElecMeter")['innerHTML']
		if(doc.scan("Meter Finalise Reason - Converted").count > 0)
			puts "Exiting so that we can fix the database and retry"
			exit 314159
		end
		
		# Click only if button not visible
		begin
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_btnGetQuotes")
		rescue
			session.find(:xpath, "//div[@onclick=\"ToggleExpandCollapse('ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN-outer', this,'ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_OuterVisibleState');\"]").click
		end
		
		#search now
		session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_btnGetQuotes").click
		#qualify if search worked
		begin
			# wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Authentication failed", "Authentication."){
				# authenticate(session.driver.browser)
			# }
			puts "Giving the website #{config['authentication_load']} seconds to load, just to be safe"
			sleep(config['authentication_load'])
			puts "Authenticating"
			authenticate(session.driver.browser)
			puts "Successfully switched to error, returning false"
			return false
		rescue Selenium::WebDriver::Error::NoSuchAlertError => e
			puts "Failed to switch to alert, exception caught"
			doc = session.html
			r = Regexp.new(/<li>Current Supplier field is mandatory<\/li>/)
			r1 = Regexp.new(/<li>No Reason field is mandatory<\/li>/)
			r2 = Regexp.new(/<li>Standing Charge field is mandatory<\/li>/)
			need_current_supplier = doc.scan(r).count > 0
			need_reason = doc.scan(r1).count > 0
			need_standing_charge = doc.scan(r2).count > 0
			
			if(need_current_supplier || need_reason)
				session.find(:xpath, "//div[@onclick=\"ToggleExpandCollapse('ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN-inner-1', this, 'ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_Inner1VisibleState');\"]").click
				if(need_current_supplier)
					session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_cmbCurrentSupplier_Input").send_keys("\ue015\ue015")
				end
				if(need_reason)
					session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_txtInContractNoReason_text").send_keys("sdgsdg")
				end
			end
			if(need_standing_charge)
				begin
					session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_rptConsumption_ctl00_txtUnits_text")
				rescue
					session.find(:xpath, "//div[@onclick=\"  ToggleExpandCollapse('ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN-inner-2', this, 'ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_Inner2VisibleState');\"]").click
				end
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_rptConsumption_ctl00_txtUnits_text").send_keys("15000")
				session.choose("ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_rblCurrentRateType_2")
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_txtStandingCharge_text").send_keys("5")
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_txtStandingCharge_text").send_keys("\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue0035")
				create_new[0] = false
			end
			return true
		end
	end
end

def get_prices (session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Get Prices", "process"){
		begin
			doc = session.find(:id, "main-container")['innerHTML']
			r = /<input id="ember\d*" required="" value=".*" class="ember-view" type="radio">/
			array = doc.scan(r)
			array1 = array[0].scan(/ember\d*/)
			session.find(:id, array1[0]).click
		rescue
			puts "Quote already selected"
		end
		session.click_button("Finish Quote")
	})
		return false
	end
	return true
end

def send_quote_email (session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Confirmation Email", "generate"){
		session.within_frame(0) do
			session.choose("Generate Quote Email")
			session.check("ctl00_MainArea_wzrdQuoting_ucQuotingWizardActions_grdPremisesMeters_ctl00_ctl04_masterCheckbox")
			session.click_button("Generate Email")
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Confirmation Email", "load"){
		session.within_frame(0) do
			session.find(:id, "ctl00_MainArea_wzrdQuoting_ucQuotingWizardActions_ucEmailPreview_wdwEmailPreview_C_btnSend").click
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Confirmation Email", "send"){
		session.driver.browser.switch_to.alert.accept()
		puts "Email was sent successfully!"
	})
		return false
	end
	return true
end
