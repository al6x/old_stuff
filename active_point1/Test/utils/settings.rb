require 'rexml/document'

#TODO Add ability to use List. (Settings.instance.list_of.element_name!)
module ::Utils		
	class Node
		def initialize node, fname
			@hash = {}
			@node, @fname = node, fname
        end
		
		def method_missing m
			unless @hash.include? m	
				name = m.to_s
				if name[name.size-1, 1] == '!'
					exact_name = name[0, name.size-1]
					n = @node.elements[exact_name]									
					raise RuntimeError, error_message(exact_name), caller unless n
				else
					n = @node.elements[name]				
				end
				if n
					if n.has_elements?
						@hash[m] = Node.new(n, @fname)
					else
						@hash[m] = Node.native_value(n.text)
					end
				else
					@hash[m] = nil
				end
			end
			return @hash[m]
		end
		
		protected
		def error_message m
			full_name = [m]
			parent = @node
			full_name << parent.name
			while parent = parent.parent
				full_name << parent.name if parent.name && !parent.name.empty?
			end
			"Undefined value of the '#{full_name.reverse.join('.')}' in the '#{@fname}' file!" 
		end
				
		def self.native_value v
			if v.to_f.to_s == v
				return v.to_f
			elsif v.to_i.to_s == v
				return v.to_i
			elsif  v == 'true'
				return true
			elsif v == 'false'
				return false
			else
				return v
			end
		end
	end
	
	class Settings < Node		
		def initialize file_name			
			super REXML::Document.new(File.open(file_name)).root, file_name
		end										
	end
end