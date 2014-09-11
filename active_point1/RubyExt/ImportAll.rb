module ImportAll
	def import_all *params
		params.each do |m|
			m.constants.each do |name|
				const_set name, m.const_get(name)
			end
		end
	end
end