class CheckType
	OBJECTIONS = "Objections"
	REJECTIONS = "Rejections"
	UNRESOLVED = "Unresolved"
	NEW = "New"
	
	class << self
		def objections
			OBJECTIONS
		end
		def rejections
			REJECTIONS
		end
		def unresolved
			UNRESOLVED
		end
		def new
			NEW
		end
		def checking_objections_rejections(input)
			if(input == OBJECTIONS || input == REJECTIONS)
				return true
			else
				return false
			end
		end
		def checking_new_unresolved(input)
			if(input == NEW || input == UNRESOLVED)
				return true
			else
				return false
			end
		end
	end
end

def search_objections_rejections(session, config, type1, type2)
	if(!CheckType.checking_objections_rejections(type1))
		puts "Input 3 not an objection or rejection"
		return false
	end
	if(!CheckType.checking_new_unresolved(type2))
		puts "Input 4 not new or unresolved"
		return false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Homepage", "load"){
		session.click_link("#{type1}: #{type2}")
	})
		return false
	end
	# Find Total
	total = find_regex(session, config, type1)
	# Find DIFY
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "#{type1}: #{type2} DIFY search", "load"){
		session.within_frame(0) do
			session.choose("DIFY")
			session.click_button("Search")
		end
	})
		return false
	end
	dify = find_regex(session, config, type1)
	# Find SME
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "#{type1}: #{type2} SME search", "load"){
		session.within_frame(0) do
			session.choose("SME")
			session.click_button("Search")
		end
	})
		return false
	end
	sme = find_regex(session, config, type1)
	# Find MB
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "#{type1}: #{type2} MB search", "load"){
		session.within_frame(0) do
			session.choose("MB")
			session.click_button("Search")
		end
	})
		return false
	end
	mb = find_regex(session, config, type1)
	if(total == (dify + sme + mb))
		puts "Test passed! Total Unresolved Objections = DIFY + SME + MB"
		puts "#{total} == #{dify} + #{sme} + #{mb}"
		return true
	else
		puts "Test Failed!"
		puts "#{total} != #{dify} + #{sme} + #{mb}"
		return false
	end
end

def find_regex(session, config, type1)
	number = 0
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold'){
		session.within_frame(0) do
			id = "ctl00_MainArea_uc#{type1[0..-2]}Search_grdSearchResults_ctl00"
			doc = session.find(:id, id)['innerHTML']
			text = doc.scan(/<strong>.+<\/strong> items in/)[0]
			number = text.scan(/[\d]+/)[0]
		end
	})
		return false
	end
	return number.to_i
end