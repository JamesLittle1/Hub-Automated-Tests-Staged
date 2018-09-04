class Products
	ELECTRICITY = "Electricity"
	GAS = "Gas"
	LANDLINE = "Landline"
	BROADBAND = "Broadband"
	MOBILE = "Mobile"
	
	class << self
		def electricity
			ELECTRICITY
		end
		def gas
			GAS
		end
		def landline
			LANDLINE
		end
		def broadband
			BROADBAND
		end
		def mobile
			MOBILE
		end
		def checking_one_of_products(input)
			if(input == ELECTRICITY || input == GAS || input == LANDLINE || input == BROADBAND || input == MOBILE)
				return true
			else
				return false
			end
		end
	end
end