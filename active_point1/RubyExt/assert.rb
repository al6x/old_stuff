class Object
	def should! cmd, arg = NotDefined
		result = case cmd								
			when :be_never_called then false
			
			when :be_nil then self.equal? nil		
			
			when :be_a
			if arg.class == Array
				arg.any?{|klass| self.is_a? klass}
			else
				self.is_a? arg
			end
			
			when :be			
			if arg.class == Array
				arg.any?{|klass| self.respond_to :is?, klass}
			else
				self.respond_to :is?, arg
			end
			
			when :include then self.include? arg
			
			when :be_in then arg.include? self
			
			when :be_true then self
			
		when :be_false then !self
			
			when :be_empty then self.empty?
			
		else
			if arg.equal? NotDefined
				self.send cmd
			else
				self.send cmd, arg
			end						
		end
		
		unless result
			unless arg.equal? NotDefined
				raise RuntimeError,  "				
ASSERTION FAILED:
#{self.inspect} should #{cmd} #{arg.inspect}
", caller
			else
				raise RuntimeError,  "				
ASSERTION FAILED:
#{self.inspect} should #{cmd}
", caller
			end
		end		
		
		return self
	end
	
	def should_not! cmd, arg = NotDefined
		result = case cmd								
			when :be_never_called then false
			
			when :be_nil then self.equal? nil
			
			when :be_a
			if arg.class == Array
				arg.any?{|klass| self.is_a? klass}
			else
				self.is_a? arg
			end
			
			when :be			
			if arg.class == Array
				arg.any?{|klass| self.respond_to :is?, klass}
			else
				self.respond_to :is?, arg
			end
			
			when :include then self.include? arg
			
			when :be_in then arg.include? self
			
			when :be_true then self
			
		when :be_false then !self
			
			when :be_empty then self.empty?
			
		else
			if arg.equal? NotDefined
				self.send cmd
			else
				self.send cmd, arg
			end						
		end
		
		if result
			unless arg.equal? NotDefined
				raise RuntimeError,  "				
ASSERTION FAILED:
#{self.inspect} should not #{cmd} #{arg.inspect}
", caller
			else
				raise RuntimeError,  "				
ASSERTION FAILED:
#{self.inspect} should not #{cmd}
", caller
			end
		end
		
		return self
	end
end