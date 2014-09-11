class LoginApp
	class << self
		attr_accessor :is_logged
	end
end

WebClient::Tools::Login.register = lambda{raise "Mест нету."}
WebClient::Tools::Login.login = lambda do |n, p|
	if n == 'admin' and p == 'admin'
		LoginApp.is_logged = true
	else
		raise "Чё за хуйня? Незнаю такого! (Введи admin/admin)"
	end
end
WebClient::Tools::Login.logout = lambda{LoginApp.is_logged = false}
WebClient::Tools::Login.logged = lambda{LoginApp.is_logged}					
WebClient::Tools::Login.user_name = lambda{"admin"}