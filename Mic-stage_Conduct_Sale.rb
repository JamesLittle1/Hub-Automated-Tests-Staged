def conduct_sale_load (session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Conduct Sale", "load"){
		session.within_frame(0) do
				session.find(:id, "ctl00_MainArea_repActionControls_ctl02_lbPageAction").click
			end
	})
		return false
	end
	return true
end

def check_for_records (session, config)
	run_quote = false
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "check_for_records", "run"){
		session.within_frame(0) do
			doc = session.find(:id, "ctl00_MainArea_wzrdConductSale_rptBusiness_ctl00_ucBusinessQuotes_grdQuotes_GridData")['innerHTML']
			if(doc.scan("No records to display").count > 0)
				run_quote = true
			end
		end
	})
		return false
	end
	if(run_quote)
		puts "Running Quote.rb"
		if(!search_customers(session, config))
			puts "Search_customers failed"
			exit -1
		end
		if(!select_customer(session, config, true))
			puts "select_customer failed"
			exit -1
		end
		if(!quote_load(session, config))
			puts "Quote page failed to load"
			exit -1
		end
		if(!quote(session, config, ARGV[0], ARGV[1]))
			puts "Quote failed"
			exit -1
		end
		if(!get_prices(session, config))
			puts "Failed to get prices"
			exit -1
		end
		if(!send_quote_email(session, config))
			puts "Failed to send quote email"
			exit -1
		end
		puts "Quote.rb was run successfully"
		
		puts "Loading customer up again"
		if(!search_customers(session, config))
			puts "Search_customers failed"
			exit -1
		end
		if(!select_customer(session, config, true))
			puts "select_customer failed"
			exit -1
		end
		if(!conduct_sale_load(session, config))
			puts "Failed to open Conduct Sale Wizard"
			exit -1
		end
	end
	return true
end

def select_quote (session, config, prod="Product::Electricity")
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Select Quote page", "load"){
		puts "Entering frame"
		session.within_frame(0) do
			# Unchecking all first
			session.html.scan(/ctl00_MainArea_wzrdConductSale_rptBusiness_ctl00_ucBusinessQuotes_grdQuotes_ctl00_ct.{1,3}_cbSelect/).each do |checkbox_id|
				checkbox = session.find(:id, checkbox_id)
				if(checkbox.checked?)
					checkbox.click
				end
			end
			puts "Getting ID"
			id = session.html.scan(/Product Type: #{prod[9..-1]}.*\n.*\n.*\n.*\n.*/)[0].scan(/<input id=\".*Select\" name/)[0].scan(/\".*\"/)[0][1..-2]
			puts "id = #{id}"
			session.check(id)
			# session.check("ctl00_MainArea_wzrdConductSale_rptBusiness_ctl00_ucBusinessQuotes_grdQuotes_ctl00_ctl07_cbSelect")
			session.click_button("ctl00_MainArea_wzrdConductSale_StartNavigationTemplateContainerID_StepNextButton")
		end
	})
		return false
	end
	return true
end

def confirm_quote (session, config, input1="", input2="")
	# Do Major Business bit if they have MB access
	
	puts "Giving the website #{config['authentication_load']} seconds to load MB authentication pop-up"
	sleep(config['authentication_load'])
	begin
		authenticate(session.driver.browser, input1, input2)
		session.within_frame(0) do
			session.all('input[type="checkbox"]').each{|box| box.set(true)}
			session.find(:xpath, "//div[@id='ember429']/div/div[2]/button").click
		end
	rescue
		puts "You do not have access to Major Business (or took over #{config['authentication_load']} seconds to load), skipping to Confirm Quote Tab"
	end
	
	# Now deal with Confirm Quote tab
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Confirm Quote page", "load"){
		session.within_frame(0) do
			session.choose("ctl00_MainArea_wzrdConductSale_radioSavingsConfirmation_0")
			session.click_button("ctl00_MainArea_wzrdConductSale_StepNavigationTemplateContainerID_StepNextButton")
		end
	})
		return false
	end
	return true
end

def additional_data (session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Additional Company Details", "load"){
		session.within_frame(0) do
			session.find(:id, "HeaderAddCompanyDetails").click
			session.click_button("ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBusiness_btnSave")
			# If error displays...
			if(session.has_xpath?("//*[@id=\"ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBusiness_vSummary\"]"))
				doc = session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBusiness_vSummary")['innerHTML']
				r = "<li>Company/Charity Number should contain exactly 8 alphanumeric characters (a-z, A-Z, 0-9).</li>"
				r1 = "Company/Charity Number is mandatory for the select business type."
				if(doc.scan(r).count > 0 || doc.scan(r1).count > 0)
					session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBusiness_txtCompanyNo_text").native.clear
					session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBusiness_txtCompanyNo_text").send_keys("12345678")
					session.click_button("ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBusiness_btnSave")
				end
			end
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Business Representative Details", "load"){
		session.within_frame(0) do
			session.find(:id, "HeaderCompanyDirector").click
			session.click_button("ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntContactDetailsOwnerDirector_btnSave")
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Bank Account Details", "load"){
		session.within_frame(0) do
			session.find(:id, "HeaderBankAccounts").click
			# Try to save bank account
			begin
				session.click_button("ctl00_MainArea_wzrdConductSale_ucAdditionalData_btnSaveBankAccounts")
			rescue Capybara::ElementNotFound => e
				session.click_button("ctl00_MainArea_wzrdConductSale_ucAdditionalData_btnNewBankAccount")
				load_attempts = 0
				for i in 0..config['loop_times']
					sleep(config['timeout_threshold'])
					begin
						if(session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_cmbAccountName_Input").value != "Haroon  Ejmahb")
							session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_cmbAccountName_Input").click
							session.find(:xpath, "/html/body/form/div[1]/div/div/ul/li[2]").click
						end
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtAccountNumber_text").native.clear
						value = session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtAccountNumber_text").value.split("_").join()
						while(value.length < 8)
							session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtAccountNumber_text").send_keys("1")
							value = session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtAccountNumber_text").value.split("_").join()
						end
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtSortCode_text").native.clear
						value = session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtSortCode_text").value.split("_").join()
						while(value.length < 6)
							session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtSortCode_text").send_keys("1")
							value = session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtSortCode_text").value.split("_").join()
						end
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtBankName_text").native.clear
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtBankName_text").send_keys("sag")
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtBranch_text").native.clear
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtBranch_text").send_keys("safdfsd")
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtAddressLine1_text").native.clear
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtAddressLine1_text").send_keys("asgdsa")
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtTownOrCity_text").native.clear
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtTownOrCity_text").send_keys("asgfds")
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtPostCode_text").native.clear
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_txtPostCode_text").send_keys("AB16 7BA")
						session.click_button("ctl00_MainArea_wzrdConductSale_ucAdditionalData_ucMntBankAccount_btnSaveAddressDetailsUC")
						session.click_button("ctl00_MainArea_wzrdConductSale_ucAdditionalData_btnSaveBankAccounts")
						puts "Waited #{i + 1} second(s) for Confirmation Email to generate."
						break
					rescue
						load_attempts += 1
						if (load_attempts > (config['timeout_threshold']*config['loop_times'] - 1))
							puts "Confirmation Email failed to generate within #{config['timeout_threshold']*config['loop_times']} seconds."
							return false
						end
					end
				end
			end
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Supply/Billing Address Details", "load"){
		session.within_frame(0) do
			session.find(:id, "HeaderAddresses").click
			session.click_button("ctl00_MainArea_wzrdConductSale_ucAdditionalData_btnSaveAddresses")
		end
	})
		return false
	end
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Major Business Details", "load"){
		begin
			session.within_frame(0) do
				session.find(:id, "HeaderMajorBusinessDetails").click
				session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_rptMajorBusiness_ctl00_MajorBusinessDetails_yieldOfSale_text").send_keys("0")
				sleep(1)
				session.click_button("Save")
			end
		rescue Capybara::ElementNotFound => e
		end
		begin
			session.within_frame(0) do
				if(session.find(:id, "ctl00_MainArea_wzrdConductSale_ucAdditionalData_vSummary").html.scan("Major Business Details need to be assigned").count > 0)
					session.click_button("Save")
				end
			end
		rescue Capybara::ElementNotFound => e
		end
	})
		return false
	end
	session.within_frame(0) do
		session.click_button("ctl00_MainArea_wzrdConductSale_StepNavigationTemplateContainerID_StepNextButton")
	end
	return true
end

def summary (session, config)
	load_attempts = 0
	for i in 0..config['loop_times']
		sleep(config['timeout_threshold'])
		begin
			session.within_frame(0) do
				# Want to do this if imgFailed present
				#DOB
				if(session.has_css?("html body#main form#aspnetForm div#main-outer div#main-inner div.clear table#ctl00_MainArea_wzrdConductSale tbody tr td table tbody tr td div#ctl00_MainArea_wzrdConductSale_ctl00_MainArea_wzrdConductSale_RadAjaxPanelStep4Panel div#ctl00_MainArea_wzrdConductSale_RadAjaxPanelStep4 div.lightest-bg.frame div.light-bg.frame div.dark-bg.frame div.light-bg.frame div div.float-left input#ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl05_imgFailed"))
					wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "DOB tick", "fill in"){
						session.click_button("ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl05_imgFailed")
					}
					wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold'){
						session.click_button("ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl05_btnSaveDoB")
					}
				end
				#Home Address
				if(session.has_css?("html body#main form#aspnetForm div#main-outer div#main-inner div.clear table#ctl00_MainArea_wzrdConductSale tbody tr td table tbody tr td div#ctl00_MainArea_wzrdConductSale_ctl00_MainArea_wzrdConductSale_RadAjaxPanelStep4Panel div#ctl00_MainArea_wzrdConductSale_RadAjaxPanelStep4 div.lightest-bg.frame div.light-bg.frame div.dark-bg.frame div.light-bg.frame div div.float-left input#ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl07_imgFailed"))
					wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Home Address tick", "fill in"){
						session.click_button("ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl07_imgFailed")
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl07_ucMntContactAddresses_cmbAddresses_Input").click
						session.find(:xpath, "/html/body/form/div[1]/div/div/ul/li[2]").click
						session.click_button("ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl07_ucMntContactAddresses_btnAddAddresses")
					}
					wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold'){
						session.click_button("ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl07_btnSaveAddresses")
					}
				end
				#Home Address History
				if(session.has_css?("html body#main form#aspnetForm div#main-outer div#main-inner div.clear table#ctl00_MainArea_wzrdConductSale tbody tr td table tbody tr td div#ctl00_MainArea_wzrdConductSale_ctl00_MainArea_wzrdConductSale_RadAjaxPanelStep4Panel div#ctl00_MainArea_wzrdConductSale_RadAjaxPanelStep4 div.lightest-bg.frame div.light-bg.frame div.dark-bg.frame div.light-bg.frame div div.float-left input#ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl08_imgFailed"))
					wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Home Address History tick", "fill in"){
						session.click_button("ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl08_imgFailed")
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl08_ucMntContactAddresses_rptAddresses_ctl02_ucMntAddress_dpMoveInDate_popupButton").click
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl08_ucMntContactAddresses_rptAddresses_ctl02_ucMntAddress_dpMoveInDate_calendar_Title").click
						session.find(:id, "rcMView_PrevY").click
						session.find(:id, "rcMView_2013").click
						session.find(:id, "rcMView_OK").click
						session.find(:xpath, "/html/body/div[2]/div/table/tbody/tr/td/table/tbody/tr[1]/td[4]").click
					}
					wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold'){
						session.click_button("ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl08_btnSaveAddresses")
					}
				end
				#DIFY
				if(session.has_css?("html body#main form#aspnetForm div#main-outer div#main-inner div.clear table#ctl00_MainArea_wzrdConductSale tbody tr td table tbody tr td div#ctl00_MainArea_wzrdConductSale_ctl00_MainArea_wzrdConductSale_RadAjaxPanelStep4Panel div#ctl00_MainArea_wzrdConductSale_RadAjaxPanelStep4 div.lightest-bg.frame div.light-bg.frame div.dark-bg.frame div.light-bg.frame div div.float-left input#ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl10_imgFailed"))
					wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "DIFY tick", "fill in"){
						session.click_button("ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl10_imgFailed")
						session.find(:id, "ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl10_cmbRenewForYou_Input").click
						begin
							session.find(:xpath, "/html/body/form/div[1]/div/div/ul/li[3]").click
						rescue
							session.find(:xpath, "/html/body/form/div[2]/div/div/ul/li[3]").click
						end
					}
					wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold'){
						session.click_button("ctl00_MainArea_wzrdConductSale_ucRuleSummaries_rptContractGroup_ctl00_rptContract_ctl00_ucRuleSummary_rptRules_ctl10_btnRenewForYou")
					}
				end
				# Want to do this either way
				session.find(:id, "ctl00_MainArea_wzrdConductSale_cmbDifto_Arrow").click
				begin
					session.find(:xpath, "/html/body/form/div[1]/div/div/ul/li[3]").click
				rescue
					session.find(:xpath, "/html/body/form/div[2]/div/div/ul/li[3]").click
				end
				session.find(:id, "ctl00_MainArea_wzrdConductSale_cmbWater_Arrow").click
				begin
					session.find(:xpath, "/html/body/form/div[1]/div/div/ul/li[3]").click
				rescue
					session.find(:xpath, "/html/body/form/div[2]/div/div/ul/li[3]").click
				end
				session.click_button("ctl00_MainArea_wzrdConductSale_StepNavigationTemplateContainerID_StepNextButton")
			end
			puts "Waited #{i + 1} second(s) for Summary page to load."
			break
		rescue
			load_attempts += 1
			if (load_attempts > (config['timeout_threshold']*config['loop_times'] - 1))
				puts "Summary page failed to load within #{config['timeout_threshold']*config['loop_times']} seconds."
				return false
			end
		end
	end
	return true
end

def preferences (session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Preferences page", "load"){
		session.within_frame(0) do
			if(session.has_css?("html body#main form#aspnetForm div#main-outer div#main-inner div.clear table#ctl00_MainArea_wzrdConductSale tbody tr td table tbody tr td div#ctl00_MainArea_wzrdConductSale_ctl00_MainArea_wzrdConductSale_RadAjaxPanelQuestionsPanel div#ctl00_MainArea_wzrdConductSale_RadAjaxPanelQuestions div#ctl00_MainArea_wzrdConductSale_ucQuestions_pnlQuestionsEle div.lightest-bg.frame div.form-row div.section.margin_b div.light-bg.margin-bottom div.light-bg.margin-bottom div#ctl00_MainArea_wzrdConductSale_ucQuestions_rptQuestionsElec_ctl00_singleQuestion_pnlCmbQuestion div.form-row-first div div#ctl00_MainArea_wzrdConductSale_ucQuestions_rptQuestionsElec_ctl00_singleQuestion_cmbAnswer.RadComboBox.RadComboBox_Vista table.rcbFocused tbody tr.rcbReadOnly td.rcbInputCell.rcbInputCellLeft input#ctl00_MainArea_wzrdConductSale_ucQuestions_rptQuestionsElec_ctl00_singleQuestion_cmbAnswer_Input.rcbInput"))
				session.find(:id, "ctl00_MainArea_wzrdConductSale_ucQuestions_rptQuestionsElec_ctl00_singleQuestion_cmbAnswer_Input").click
				begin
					session.find(:xpath, "/html/body/form/div[1]/div/div/ul/li[3]").click
				rescue
					session.find(:xpath, "/html/body/form/div[2]/div/div/ul/li[3]").click
				end
				session.click_button("ctl00_MainArea_wzrdConductSale_ucQuestions_btnSave")
				session.click_button("ctl00_MainArea_wzrdConductSale_StepNavigationTemplateContainerID_StepNextButton")
			elsif(session.has_css?("html body#main form#aspnetForm div#main-outer div#main-inner div.clear table#ctl00_MainArea_wzrdConductSale tbody tr td table tbody tr td div#ctl00_MainArea_wzrdConductSale_ctl00_MainArea_wzrdConductSale_RadAjaxPanel1Panel div#ctl00_MainArea_wzrdConductSale_RadAjaxPanel1 div.lightest-bg.frame div.light-bg.frame div#ctl00_MainArea_wzrdConductSale_ucVerbals_rptVerbal_ctl00_ucVerbal-verbal-heading.meter-inner-heading.margin-top.clear input#ctl00_MainArea_wzrdConductSale_ucVerbals_rptVerbal_ctl00_ucVerbal_btnEContract1.contractTypeSelectorButton"))
				puts "Skipping Preferences screen"
				return true
			end
		end
	})
		return false
	end
	return true
end

def verbal (session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Verbal Contract page", "load"){
		session.within_frame(0) do
			session.click_button("Verbal Contract")
		end
	})
		return false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Verbal Contract", "generate"){
		session.within_frame(0) do
			session.find(:id, "ctl00_MainArea_wzrdConductSale_ucVerbals_rptVerbal_ctl00_ucVerbal_btnStart").click
		end
	})
		return false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Verbal Contract", "play"){
		session.within_frame(0) do
			session.find(:id, "ctl00_MainArea_wzrdConductSale_ucVerbals_rptVerbal_ctl00_ucVerbal_btnStop").click
		end
	})
		return false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Verbal Contract confirmation", "load"){
		session.within_frame(0) do
			session.find(:id, "ctl00_MainArea_wzrdConductSale_ucVerbals_rptVerbal_ctl00_ucVerbal_radWdwConfirm_C_btnConfirm").click
		end
	})
		return false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Verbal Contract", "confirm."){
		session.within_frame(0) do
			session.find(:id, "ctl00_MainArea_wzrdConductSale_StepNavigationTemplateContainerID_StepNextButton").click
		end
	})
		return false
	end
	
	return true
end

def finish (session, config)
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Confirmation Email", "generate"){
		session.within_frame(0) do
			session.find(:id, "ctl00_MainArea_wzrdConductSale_ucConductSaleWizardActions_rdoEmail").click
			session.find(:id, "ctl00_MainArea_wzrdConductSale_ucConductSaleWizardActions_grdContracts_ctl00_ctl02_ctl00_ClientSelectSelectCheckBox").click
			session.find(:id, "ctl00_MainArea_wzrdConductSale_ucConductSaleWizardActions_btnActionEmails").click
		end
	})
		return false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Confirmation Email", "send"){
		session.driver.browser.switch_to.alert.accept()
		puts "Email has been sent successfully!"
	})
		return false
	end
	return true
end