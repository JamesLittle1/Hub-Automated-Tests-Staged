def wait_for_authentication_to_load(session, config, loop_times, timeout_threshold, noun="", verb="")
	load_attempts = 0
	for i in 0..config[loop_times]
		sleep(config[timeout_threshold])
		begin
			yield
			if(noun != "" || verb != "")
				puts "Waited #{i + 1} second(s) for " + noun + " to " + verb + "."
			end
			break
		rescue Selenium::WebDriver::Error::NoSuchAlertError, Capybara::ModalNotFound, Capybara::ElementNotFound, RuntimeError, Selenium::WebDriver::Error::ElementClickInterceptedError, NoMethodError
			load_attempts += 1
			if(load_attempts > (config[loop_times] - 1))
				if(noun != "" || verb != "")
					puts(noun + " failed to " + verb + " within #{config[timeout_threshold]*config[loop_times]} seconds.")
				end
				return false
			end
			next
		end
	end
	return true
end
