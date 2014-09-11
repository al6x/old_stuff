class Login < WComponent	
	children :@name, :@password, :@ok, :@cancel
	
	def on
		@on ||= {}
	end
	
	def build
		@name, @password = WTextField.new, WTextField.new.set(:password => true)
		@ok = WButton.new `Ok`, self, &on[:ok]
		@cancel = WButton.new `Cancel`, &on[:cancel]
	end
	
	def name; @name.text end
	def password; @password.text end
end