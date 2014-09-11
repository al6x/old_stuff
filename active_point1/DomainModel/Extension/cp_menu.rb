WebClient::Tools::Menu.parent_get = lambda{|o| o.parent}
WebClient::Tools::Menu.each_child = lambda{|o, callback| raise "fuck" unless callback; o.each :children, &callback} 
WebClient::Tools::Menu.name_get = lambda{|o| o.name}