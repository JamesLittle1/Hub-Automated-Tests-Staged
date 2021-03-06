def quote_load(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Quote page", "load"){
		session.find(:id, "ctl00_MainArea_repActionControls_ctl01_lbPageAction").click
	})
		return false
	end
	return true
end

def quote(session, config, input1="", input2="", prod)
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Quote", "process"){
		begin
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBusiness_ctl00_rptPremises_ctl00_ucQuotingPremises_imbPremisesSelect").click
		rescue
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBusiness_ctl00_lblBusinessName").click
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBusiness_ctl00_rptPremises_ctl00_ucQuotingPremises_imbPremisesSelect").click
		end
		session.find(:id, "ctl00_MainArea_wzrdQuoting_ucCompanyCreditScore_txtCreditScore_text").native.clear
		session.find(:id, "ctl00_MainArea_wzrdQuoting_ucCompanyCreditScore_txtCreditScore_text").send_keys("100")
		session.find(:id, "ctl00_MainArea_wzrdQuoting_StartNavigationTemplateContainerID_StepNextButton").click
	})
		return false
	end
	
	create_new = [true]
	#create_new = [false] # remove after testing
	case prod
		when Products.send(:electricity), Products.send(:gas)
			searching = search_for_meter(session, config, create_new, input1, input2, prod)
		when Products.send(:landline), Products.send(:broadband), Products.send(:mobile)
			search_for_telco(session, config, create_new, prod)
	end
	
	return true
end

def get_prices (session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Get Prices", "process"){
		begin
			doc = session.find(:id, "main-container")['innerHTML']
			r = /<input id="ember\d*" required="" value=".*" class="ember-view" type="radio">/
			array = doc.scan(r)
			array1 = array[0].scan(/ember\d*/)
			session.find(:id, array1[0]).click
			puts "New Quote Selected"
		rescue
			puts "Quote already selected (or page still loading)"
			sleep(1)
		end
		session.click_button("Finish Quote")
	})
		return false
	end
	return true
end

def confirm_quote(session, config, prod)
	if(!wait_for_page_to_load(session, config, 'loop_times_customer_search', 'timeout_threshold_customer_search', "Finish Tab", "load"){
		begin
			session.within_frame(0) do
				session.click_button("Exit")
			end
		rescue Capybara::ExpectationNotMet
			session.click_button("Exit")
		end
	})
		puts "Failed to finish #{prod} quote (couldn't click exit on finish tab)"
		puts "Html for page (to analyse error):"
		begin
			session.within_frame(0) do
				puts session.html
			end
		rescue Capybara::ExpectationNotMet
			puts session.html
		end
		return false
	end
	retries = 10
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Confirm quote", "complete"){
		begin
			session.within_frame(0) do
				while(true)
					doc = session.find(:id, "ctl00_MainArea_ProductMatrix1_ucProductMatrix1_ProductMatrixTable")['innerHTML']
					if(doc.scan(/#{prod}.*<\/td><td.*\n.*\n.*background-color:#3030FF/).count > 0)
						puts "Successfully quoted #{prod}!"
						break
					else
						if(retries > 0)
							sleep(1)
							retries -= 1
						else
							puts "#{prod} quote not showing up!"
							exit -1
						end
					end
				end
			end
		rescue Capybara::ExpectationNotMet
			while(true)
				doc = session.find(:id, "ctl00_MainArea_ProductMatrix1_ucProductMatrix1_ProductMatrixTable")['innerHTML']
				if(doc.scan(/#{prod}.*<\/td><td.*\n.*\n.*background-color:#3030FF/).count > 0)
					puts "Successfully quoted #{prod}!"
					break
				else
					if(retries > 0)
						sleep(1)
						retries -= 1
					else
						puts "#{prod} quote not showing up!"
						exit -1
					end
				end
			end
		end
	})
		puts "Failed to confirm #{prod} quote"
		return false
	end
	return true
end

# Methods from above
def search_for_meter (session, config, create_new, input1="", input2="", prod)
	puts "Entered search_for_meter"
	moved_into_premises(session, config)
	
	if(create_new[0])
		session.click_link("Search")
		session.find(:id, "ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_txtPostCode_text").native.clear
		session.find(:id, "ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_txtPostCode_text").send_keys("SM4 5BE")
		session.find(:id, "ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_txtPremises_text").native.clear
		session.click_button("ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_btnSearch")
		wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Meter Results", "load"){
			session.find(:id, "ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_grdSearch_ctl00_ctl07_GECBtnExpandColumn").click
		}
		if(!wait_for_authentication_to_load(session, config, 'loop_times', 'timeout_threshold', "Meter Result", "Expand"){
			session.accept_alert do
				case prod
					when Products.send(:electricity)
						session.click_button("ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_grdSearch_ctl00_ctl09_Detail20_ctl04_btnAddMPAN")
					when Products.send(:gas)
						session.click_button("ctl00_MainArea_wzrdQuoting_ucSearchGBUtilities_grdSearch_ctl00_ctl09_Detail21_ctl04_btnAddMPR")
				end
				#session.driver.browser.switch_to.alert.accept()
			end
		})
			return false
		end
		create_new[0] = false
	end
	session.click_link(prod)
	
	# Checking that a meter exists
	puts "Checking if meter exists"
	# Wait for element to load
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "#{prod} panel", "load"){
		case prod
			when Products.send(:electricity)
				session.find(:id, "ctl00_MainArea_wzrdQuoting_pnlElectric")
			when Products.send(:gas)
				session.find(:id, "ctl00_MainArea_wzrdQuoting_pnlGas")
		end
	})
		raise "#{prod} panel not found"
	end
	case prod
		when Products.send(:electricity)
			if(session.find(:id, "ctl00_MainArea_wzrdQuoting_pnlElectric")['innerHTML'].scan("ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_pnlElecMeter").count ==0)
				create_new[0] = true
				return true
			end
		when Products.send(:gas)
			if(session.find(:id, "ctl00_MainArea_wzrdQuoting_pnlGas")['innerHTML'].scan("ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_pnlGasMeter").count ==0)
				create_new[0] = true
				return true
			end
	end
	
	#Checking that the meter is quotable - else need to change database
	case prod
		when Products.send(:electricity)
			doc = session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_pnlElecMeter")['innerHTML']
		when Products.send(:gas)
			doc = session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_pnlGasMeter")['innerHTML']
	end
	if(doc.scan("Meter Finalise Reason - Converted").count > 0)
		puts "Exiting so that we can fix the database and retry"
		exit 314159
	end
	
	# Click only if button not visible
	case prod
		when Products.send(:electricity)
			begin
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_btnGetQuotes")
			rescue
				session.find(:xpath, "//div[@onclick=\"ToggleExpandCollapse('ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN-outer', this,'ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_OuterVisibleState');\"]").click
			end
			# now fill in info before clicking get prices
			fill_in_get_prices_info(session, prod)
			#search now
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_btnGetQuotes").click
		when Products.send(:gas)
			begin
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_btnGetQuotes")
			rescue
				session.find("html body#main form#aspnetForm div#main-outer div#main-inner div.clear table#ctl00_MainArea_wzrdQuoting tbody tr td table tbody tr td div.lightest-bg.frame div.scrollable div#ctl00_MainArea_wzrdQuoting_radmultipageProductTypes div#ctl00_MainArea_wzrdQuoting_RadPageView3 div.light-bg.frame div#ctl00_MainArea_wzrdQuoting_pnlGas div.medium-bg.no-border div#ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_pnlGasMeter.meter-gas div#ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_pnlExpand div.hover-pointer.float-right.meter-outer-arrow.collapsed").click
			end
			# now fill in info before clicking get prices
			fill_in_get_prices_info(session, prod)
			#search now
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_btnGetQuotes").click
	end
		case prod
			when Products.send(:electricity)
				id = "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_vSummaryElectric"
			when Products.send(:gas)
				id = "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_vSummaryGas"
		end
		# Adding wait so we're sure page would have started loading this if authentication needed
		sleep(2)
		for i in 1..config['loop_times_extended']
			begin
				if(session.html.scan(/style=\"transform: translate3d\([\d]+\.?[\d]*%/).count > 0)
					auth = true
					break
				elsif(session.find(:id, id)['innerHTML'].scan(/Please fix the following error\(s\):.*/).count > 0)
					retries = 3
					if(session.find(:id, id)['innerHTML'].scan(/Please fix the following error\(s\):.*/).scan(/Please save Change of Tenancy details/).count > 0 && retries > 0)
						puts "Attempting to fix errors:"
						puts session.find(:id, id)['innerHTML'].scan(/Please fix the following error\(s\):.*/)
						moved_into_premises(session, config)
						# retry 3 times
						case prod
							when Products.send(:electricity)
								session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_btnGetQuotes").click
							when Products.send(:gas)
								session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_btnGetQuotes").click
						end
						retries -= 1
					else
						auth = false
						puts "auth failed because of following errors:"
						puts session.find(:id, id)['innerHTML'].scan(/Please fix the following error\(s\):.*/)
						break
					end
				else
					next
					sleep(1)
				end
			rescue NoMethodError, Capybara::ElementNotFound
				if(i == config['loop_times_extended'])
					puts "HTML output after timeout:"
					puts session.html # on last attempt print the html output so we can see what's happening
				end
				puts "Page still loading"
				sleep(1)
			end
		end
		
		if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Get Prices Authentication", "pop-up"){
			puts "auth = #{auth}"
			if(auth)
				puts "In auth"
				for i in 0..config['loop_times_customer_search']
					begin
						session.driver.browser.switch_to.alert
						puts "Alert successfully switched to"
						break
					rescue Selenium::WebDriver::Error::NoSuchAlertError
						puts "Authentication still loading"
						sleep(1)
					end
				end
				puts "Exited loop, now trying to authenticate"
				authenticate(session.driver.browser, input1, input2)
				# puts "Successfully switched to error, returning false"
				# return false
			elsif(session.find(:id, id)['innerHTML'].scan(/Please fix the following error\(s\)/).count > 0)
				puts "Errors occurred - run test non-headlessly to see them."
				raise "Errors on trying to click Get Prices"
			end
		})
			return false
		end
end

def fill_in_get_prices_info(session, prod)
	case prod
		when Products.send(:electricity)
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_pnlContractMoreInfo").click
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_cmbCurrentSupplier_Input").send_keys("\ue015\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_txtInContractNoReason_text").send_keys("sdgsdg")
			begin
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_rptConsumption_ctl00_txtUnits_text")
			rescue
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_pnlConsumptionRates").click
			end
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_rptConsumption_ctl00_txtUnits_text").send_keys("15000")
			session.choose("ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_rblCurrentRateType_2")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_txtStandingCharge_text").send_keys("5")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_txtStandingCharge_text").send_keys("\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue0035")
		when Products.send(:gas)
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_pnlContractMoreInfo").click
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_cmbCurrentSupplier_Input").send_keys("\ue015\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_txtInContractNoReason_text").send_keys("sdgsdg")
			begin
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPANS_ctl00_ucQuotingMPAN_rptConsumption_ctl00_txtUnits_text")
			rescue
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_pnlConsumptionRates").click
			end
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_txtUnits_text").send_keys("15000")
			session.choose("ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_rblCurrentRateType_2")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_txtStandingCharge_text").send_keys("5")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMPRs_ctl00_ucQuotingMPR_txtStandingCharge_text").send_keys("\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue003\ue0035")
	end
end

def moved_into_premises(session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times_short', 'timeout_threshold_short', "Service DC and Quotes tab", "load"){
		if(session.find(:id, "ctl00_MainArea_wzrdQuoting_ucROPremises_cmbCoT_Input").value != "No")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_ucROPremises_cmbCoT_Input").send_keys("\ue015\ue015")
		end
		session.find(:id, "ctl00_MainArea_wzrdQuoting_ucROPremises_btnSaveCoT").click
	})
		raise "Service DC and Quotes tab timed out"
	end
end

def search_for_telco(session, config, create_new, prod)
	moved_into_premises(session, config)
	session.click_link(prod)
	
	if(create_new[0])
		session.click_button("ctl00_MainArea_wzrdQuoting_btnAddMeter")
		create_new[0] = false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "New #{prod}", "add"){
		case prod
			when Products.send(:landline), Products.send(:mobile)
				if(!session.find(:id, "ctl00_MainArea_wzrdQuoting_rpt#{prod}_ctl00_ucQuoting#{prod}_rbtNewConnection").checked?)
					session.choose("ctl00_MainArea_wzrdQuoting_rpt#{prod}_ctl00_ucQuoting#{prod}_rbtNewConnection")
					sleep(4)
				end
			when Products.send(:broadband)
				if(!session.find(:id, "ctl00_MainArea_wzrdQuoting_rpt#{prod}_ctl00_ucQuoting#{prod}_chkNewConnection").checked?)
					session.check("ctl00_MainArea_wzrdQuoting_rpt#{prod}_ctl00_ucQuoting#{prod}_chkNewConnection")
					sleep(4)
				end
		end
		case prod
			when Products.send(:landline)
				if(session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_cmbLineType_Input").value == "- Select -")
					session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_cmbLineType_Input").send_keys("\ue015")
				end
		end
	})
		return false
	end
	
	begin
		session.find(:id, "ctl00_MainArea_wzrdQuoting_rpt#{prod}_ctl00_ucQuoting#{prod}_cmbCurrentSupplier_Input")
	rescue
		session.find(:id, "ctl00_MainArea_wzrdQuoting_rpt#{prod}_ctl00_ucQuoting#{prod}_pnlMoreInformation").click
	end
	
	case prod
		when Products.send(:landline)
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_txtChannel_text").send_keys("123")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_cmbCurrentSupplier_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_cmbChosenSupplier_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_cmbChosenTariff_Input").click
			sleep(3) # wait for page to load
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_cmbChosenTariff_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_cmbContractPeriod_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_cmbTier_Input").send_keys("\ue015")
			begin
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_numEstimatedNewMonthlyCallSpend_text").send_keys("20")
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_numAnnualSaving_text").send_keys("10")
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_numContractSaving_text").send_keys("10")
			rescue Capybara::ElementNotFound
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_numTotalCurrentMonthlySpend_text").send_keys("30")
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_numTotalNewMonthlySpend_text").send_keys("20")
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptLandline_ctl00_ucQuotingLandline_numTotalMonthlySaving_text").send_keys("10")
			end
		when Products.send(:broadband)
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBroadband_ctl00_ucQuotingBroadband_cmbChosenSupplier_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBroadband_ctl00_ucQuotingBroadband_cmbChosenTariff_Input").click
			sleep(4)
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBroadband_ctl00_ucQuotingBroadband_cmbChosenTariff_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBroadband_ctl00_ucQuotingBroadband_cmbContractPeriod_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBroadband_ctl00_ucQuotingBroadband_numTotalMonthlyCost_text").send_keys("20")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBroadband_ctl00_ucQuotingBroadband_numAnnualSaving_text").send_keys("10")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBroadband_ctl00_ucQuotingBroadband_numContractSaving_text").send_keys("10")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptBroadband_ctl00_ucQuotingBroadband_cmbCurrentSupplier_Input").send_keys("\ue015")
		when Products.send(:mobile)
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_cmbProductType_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_cmbCurrentSupplier_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_cmbChosenSupplier_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_cmbChosenTariff_Input").click
			sleep(3) # wait for page to load
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_cmbChosenTariff_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_cmbDevice_Input").send_keys("\ue015")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_dpStartDate_popupButton").click
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_dpStartDate_calendar_Title").click
			session.find(:id, "rcMView_2023").click
			session.find(:id, "rcMView_OK").click
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_dpStartDate_calendar_Top").click_link("27")
			session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_numYield_text").send_keys("100")
			
			begin
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_numEstimatedNewMonthlyCallSpend_text").send_keys("20")
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_numAnnualSaving_text").send_keys("30")
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_numContractSaving_text").send_keys("30")
			rescue Capybara::ElementNotFound
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_numTotalCurrentMonthlySpend_text").send_keys("10")
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_numTotalNewMonthlySpend_text").send_keys("20")
				session.find(:id, "ctl00_MainArea_wzrdQuoting_rptMobile_ctl00_ucQuotingMobile_numTotalMonthlySaving_text").send_keys("10")
			end
	end
	session.click_button("Save #{prod}")
	
	sleep(2)
	session.click_button("Save #{prod}")
end
