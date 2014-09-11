module Kernel
	def raise_without_self *args
		error, message, the_self = nil
		if args.size == 1
			error = RuntimeError
			message = args[0]
			the_self = self
		elsif args.size == 2
			message, the_self = args
			error = RuntimeError
		elsif args.size == 3
			error, message, the_self = args
		else
			raise RuntimeError, "Invalid arguments!", caller
		end
		
		the_self = the_self.is_a?(Array) ? the_self : [the_self]
		
		list = []
		the_self.each do |s|
			klass = (s.class == Class or s.class == Module) ?	s : s.class
			klass.ancestors.each do |a|
				next if a == Object or a == Module
				name = a.name
				path = nil
				if RubyExt::Resource.class_exist?(name)		            
					path = RubyExt::Resource.class_to_virtual_file(name)
					path.sub!(".rb", "")
				else
					path = name.gsub("::", "/")
				end
				list << /#{path}/
			end
		end
		
		stack = caller
		stack = stack.delete_if do |line|
			list.any?{|re| line =~ re} and line !~ /\/Spec\// # Do not exclude Spec stacktrace.
		end
		raise error, message, stack		
	end
	
	def respond_to sym, *args
		return nil if not respond_to? sym
		send sym, *args
	end
	
	#	def _ &b
	#		raise "Block isn't provided!" unless b
	#		return b 
	#	end
	
	def singleton_class(&block)
		if block_given?
		(class << self; self; end).class_eval(&block)
		self
		else
		(class << self; self; end)
		end
	end		
end