module Cache		
	DISABLED = false
	
	warn "CASHE DISABLED" if DISABLED 
	
	# It's not a good idea to mix Business Logic and Performance optimization, 
	# so i think these methods should be never used.
	#	def cached *methods
	#		Cache.cached self, *methods
	#	end	
	#	
	#	def cached_with_params *methods
	#		Cache.cached_with_params self, *methods
	#	end
	
	@versions, @alias_counter, @monitor = Hash.new{should! :be_never_called}, 0, Monitor.new
	class << self
		
		def alias_counter
			@alias_counter += 1
			return :"m#{@alias_counter}"
		end		
		
		def cached *arg
			vnames, klass, methods = parse_and_check_arguments *arg
			
			return if DISABLED						
			methods.each do |m|				
				als = (m.to_s =~ /^[_a-zA-Z0-9]+$/) ? m : RubyExt::Cache.alias_counter.to_sym 
				
				klass.class_eval{alias_method :"cached_#{als}", :"#{m}"}
				unless vnames.is_a? Array
					script = Cache["single_version_without_args.txt"].substitute binding					
					@versions[vnames] = 0 unless @versions.include? vnames
				else
					vnames_str = vnames.collect{|vname| "'#{vname}' => nil"}.join(', ')
					script = Cache["multiple_version_without_args.txt"].substitute binding
					vnames.each{|vname| @versions[vname] = 0 unless @versions.include? vname}
				end
				klass.class_eval script, __FILE__, __LINE__								
			end			
		end
		
		def cached_with_params *arg
			vnames, klass, methods = parse_and_check_arguments *arg
			
			return if DISABLED			
			methods.each do |m|
				als = (m.to_s =~ /^[_a-zA-Z0-9]+$/) ? m : RubyExt::Cache.alias_counter
				
				klass.class_eval{alias_method :"cached_#{als}", :"#{m}"}
				unless vnames.is_a? Array
					script = Cache["single_version_with_args.txt"].substitute binding					
					@versions[vnames] = 0 unless @versions.include? vnames
				else
					vnames_str = vnames.collect{|vname| "'#{vname}' => nil"}.join(', ')
					script = Cache["multiple_version_with_args.txt"].substitute binding
					vnames.each{|vname| @versions[vname] = 0 unless @versions.include? vname}
				end
				klass.class_eval script, __FILE__, __LINE__
			end	
		end
		
		def version name
			@versions[name]
		end
		
		def update *names
			names.each do |n| 
				n = n.to_s
				@versions[n] = 0 unless @versions.include? n 
				@versions[n] += 1
			end
		end
		
		attr_reader :monitor
		
		protected
		def parse_and_check_arguments *arg
			arg.size.should! :>=, 3
			
			version_names = arg[0]
			if version_names.is_a? Array
				version_names.size.should! :>, 0
				version_names = version_names.collect{|n| n.to_s}
			else
				version_names = version_names.to_s
			end
			
			klass = arg[1]
			klass.class.should! :be, [Class, Module]
			
			methods = arg[2..arg.size]			
			defined = klass.instance_methods
			methods.each do |m|
				raise "Invalid method_name '#{m}'!" unless defined.include? m.to_s
			end
			return version_names, klass, methods
		end		
	end
end