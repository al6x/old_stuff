class Marshal		
#	DUMP_TYPES = {
#		Fixnum => lambda{|o| [o.to_s, "FNUM"]},			
#		Bignum => lambda{|o| [o.to_s, "BNUM"]},			
#		Float => lambda{|o| [o.to_s, "FLNUM"]},			
#		NilClass => lambda{|o| ["nil", "NIL"]},			
#		String => lambda{|o| [o, "STR"]},
#		Symbol => lambda{|o| [":#{o.to_s}", "SYM"]}, 			
#		FalseClass => lambda{|o| ["false", "FLS"]},			
#		TrueClass => lambda{|o| ["true", "TRU"]},			
#		DateTime => lambda{|o| [o.to_s, "DATE"]},
#		
#		Class => lambda{|o| [o.name, "CLS"]},			
#		Proc => lambda{|o| [o.to_ruby, "PROC"]},
#		Engine::StreamID => lambda{|o| assert(o.sid).is_a(String); [o.sid.to_s, "STREAM"]},
#	}
#	
#	LOAD_TYPES = {
#		"FNUM" => lambda{|s| s.to_i},			
#    "BNUM" => lambda{|s| s.to_i},			
#    "FLNUM" => lambda{|s| s.to_f},			
#    "NIL" => lambda{|s| nil},			
#    "STR" => lambda{|s| s},
#    "SYM" => lambda{|s| s[1..s.size].to_sym}, 			
#    "FLS" => lambda{|s| false},			
#    "TRU" => lambda{|s| true},			
#    "DATE" => lambda{|s| DateTime.parse s},
#    
#    "CLS" => lambda{|s| eval(s, TOPLEVEL_BINDING, __FILE__, __LINE__)},			
#    "PROC" => lambda{|s| eval(s, TOPLEVEL_BINDING, __FILE__, __LINE__)},
#    "STREAM" => lambda{|s| Engine::StreamID.new s},
#	}	
end