class Login < WComponent
	extend Managed
	scope :session
	
	children :@blogin, :@bregister, :@blogout, :@name, :@password
	
	def initialize
		super
		@message = nil
		@name, @password = WTextField.new, WTextField.new 
		@blogin = WButton.new to_l("Login"), self do
			begin
				@message = nil				
				Login.login.call @name.text, @password.text					
			rescue Exception => e
				@message = e.message
			end
			refresh
		end
		@bregister = WButton.new to_l("Register") do
			Login.register.call
		end
		@blogout = WButton.new to_l("Logout") do
			@message = nil 
			Login.logout.call			
			refresh			
		end		
	end
	
	class << self
		attr_accessor :login, :register, :logout, :logged, :user_name
	end
end