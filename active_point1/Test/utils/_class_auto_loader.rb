require 'monitor'
require 'utils/log'
require 'utils/stack_trace'

module ::Utils
	class ClassAutoLoader        
		include Log
        #        MONITOR = Monitor.new
	
		class QualifiedName
			attr_reader :name, :scope
			def initialize params
				if params[:file]
					names = params[:file].sub(".rb", "").split('/')
					@name = names.pop
					@scope = names.join('::')										
				else                                                                                
					scope = params[:scope]
					@scope = (scope == Object or scope == Module) ? "" : "#{scope}"                                                            
					@name = params[:name].to_s
                end				
                # TODO It's hack
                # try to execute this code:
                # 
                #class Module	
                #	def const_missing const
                #		p self.to_s
                #	end
                #end
                #
                #class A
                #    class << self
                #        def a
                #            p self
                #            MissingConst
                #        end
                #    end
                #end
                #
                #A.a
                #
                # the output will be:
                # A
                # "#<Class:A>"
                #
                @scope = @scope.gsub("#<Class:", "").gsub(">", "") 
			end
		
			def simple?; @scope.empty? end
		
			def to_upper_scope!
				unless simple?
					terms = @scope.split('::')
					terms.pop
					@scope = terms.join('::')
				end
				self
			end
		
			def to_s; simple? ? @name : @scope+"::"+@name end		
            
            def dir; QualifiedName.class_to_path(to_s) end
            
            def file; QualifiedName.class_to_path(to_s) + ".rb" end
            
            def self.class_to_path klass_name
                ClassAutoLoader.base_dir+'/'+klass_name.gsub('::', '/')
			end
		end
	
		class ScriptLoader
			def initialize qname
				@qname = qname
			end					
		
			def load
                current_scope, nesting = "", []
                @qname.scope.split("::").each do |level|
                    current_scope += "::#{level}"
                    type = eval current_scope, TOPLEVEL_BINDING
                    nesting << [level, (type.class == Module ? "module" : "class")]
                end                        
                begining = nesting.collect{|l, t| "#{t} #{l};"}.join(' ')
                ending = nesting.collect{"end"}.join('; ')
                        
                if File.exist?(@qname.file)                    
					script = File.read(@qname.file)						                        
#                    scope_eval script, @qname.file
                    script = "#{begining}#{script} \n#{ending}"
					eval script, TOPLEVEL_BINDING, @qname.file
				elsif File.directory?(@qname.dir)
#                    scope_eval "module #{@qname.name}; end;"
					eval "#{begining} module #{@qname.name}; end; #{ending}", TOPLEVEL_BINDING				
				else
					return false
				end
				return true
			end 
            
#            def scope_eval script, file = ""
#                scope = @qname.scope
#                if scope.empty?
#                    eval script, TOPLEVEL_BINDING, file
#                else
#                    scope = eval scope
#                    if scope.class == Class
#                        scope.class_eval script, file
#                    else
#                        scope.module_eval script, file
#                    end
#                end
#            end
		end
	
		def self.base_dir; 
			@base_dir ||= File.expand_path('.')
        end
        
		def self.base_dir= dir; 
			@base_dir = File.expand_path(dir)			
		end
	
		@infinity_cycle = nil						
		def self.load_class mself, const            
            #			MONITOR.synchronize do
            qname = QualifiedName.new :scope => mself, :name => const
            simple_also_tried = false
            begin
                simple_also_tried = qname.simple?                
                loader = ScriptLoader.new qname
                if loader.load	
                    if qname.to_s == @infinity_cycle
                        raise NameError, "class name does not corresponds file name '#{qname.file}'", 
                            StackTrace.remove_file(caller, __FILE__)
                    end
                    @infinity_cycle = qname.to_s
                    result = eval qname.to_s, TOPLEVEL_BINDING			
                    return result if result				
                    raise NameError, "uninitialized constant #{qname}", 
                        StackTrace.remove_file(caller, __FILE__)
                end
                qname.to_upper_scope!
            end until qname.simple? and simple_also_tried
				
            raise NameError, "uninitialized constant #{qname}", StackTrace.remove_file(caller, __FILE__)                    
            #			end
		end			
	
		def self.reload_file file
            #			MONITOR.synchronize do
            begin
                relative_path = file.to_s.gsub("\\", "/").sub(base_dir.to_s.gsub("\\", "/"), '').
                    sub(/\//, '')										
					
                qname = QualifiedName.new :file => relative_path
                loader = ScriptLoader.new qname
                loader.load						
					
                log.info "The '#{file}' File has been reloaded."
            rescue Exception => e
                log.error e
            end
            #			end
		end				
	end
end

class Module
	alias_method :old_const_missing, :const_missing
	def const_missing const
		::Utils::ClassAutoLoader.load_class self, const
	end
end