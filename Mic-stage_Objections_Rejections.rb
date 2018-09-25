class Type1
	OBJECTIONS = "Objections"
	REJECTIONS = "Rejections"
	
	class << self
		def objections
			OBJECTIONS
		end
		def rejections
			REJECTIONS
		end
		def checking_objections_rejections(input)
			if(input == OBJECTIONS || input == REJECTIONS)
				return true
			else
				return false
			end
		end
	end
end

class Type2
	UNRESOLVED = "Unresolved"
	NEW = "New"
	
	class << self
		def unresolved
			UNRESOLVED
		end
		def new
			NEW
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

class Type3
	TOTAL = "Total"
	DIFY = "DIFY"
	SME = "SME"
	MB = "MB"
	
	class << self
		def total
			TOTAL
		end
		def dify
			DIFY
		end
		def sme
			SME
		end
		def mb
			MB
		end
		
		def checking_total_dify_sme_mb(input)
			if(input == TOTAL || input == DIFY || input == SME || input == MB)
				return true
			else
				return false
			end
		end
		def check(input)
			if(input == DIFY || input == SME || input == MB)
				return true
			else
				return false
			end
		end
	end
end

def search_objections_rejections(session, config, type1, type2, type3, ret)
	if(!Type3.checking_total_dify_sme_mb(type3))
		puts "Input 5 not in {total, DIFY, SME, MB}"
		return false
	end
	
	if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "Homepage", "load"){
		session.click_link("#{type1}: #{type2}")
	})
		return false
	end
	
	# Find Total/DIFY/SME/MB
	if(Type3.check(type3))
		if(!wait_for_page_to_load(session, config, 'loop_times', 'timeout_threshold', "#{type1}: #{type2} #{type3} search", "load"){
			session.within_frame(0) do
				session.choose(type3)
				session.click_button("Search")
			end
		})
			return false
		end
	end
	ret[type3] = find_regex(session, config, type1)
	return true
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