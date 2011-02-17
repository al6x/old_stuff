class TemplateHelper				
	extend Log
	
	class WGUIERuby < Erubis::Eruby
		include OpenConstructor
		#		def src= src
		#			instance_variable_set "@src", src
		#		end
		#		
		#		def src
		#			instance_variable_get "@src"
		#		end
		#		def escaped_expr code
		#			return code
		#		end
	end		
	
	@cache = {}
	class << self				
		attr_reader :cache
		#		def self.caller_path the_caller
		#			return File.dirname(the_caller[0].split(/:[0-9]/)[0])			
		#        end
		# Render teplate
		# 
		# file - template file name, if not specified for template will be used file with the same name as 
		# Class.rb => Class.TEMPLATE_EXTENSION
		# 		
		# preprocessing - should file be preprocessed and all '#some_name' changed to '<%= @some_name.to_html session %>'	
		def render_template klass, *args		
			begin
				params = args[0] || {}				
				resource = params[:resource] || TEMPLATE_EXTENSION																
				
				bind = params[:binding] || binding
				 
				if CONFIG[:template_cache] 				
					template_id = generate_template_id klass, resource
					src = @cache[template_id]
					if !src or $debug
						input = read_template klass, resource
						input = preprocess_template input, params					
						src = WGUIERuby.new(input).src
						@cache[template_id] = src
					end					 
					html = WGUIERuby.new(nil).set!(:src => src).result(bind)
				else
					input = read_template klass, resource
					input = preprocess_template input, params					
					html = WGUIERuby.new(input).result(bind)
				end
				
				validate(html, klass) if $debug
				
				return html 
			rescue Exception => e
				log.error "Error in rendering template '#{resource}' for '#{klass.name}' Class!"
				raise e
			end
		end	
		
		def generate_template_id klass, resource
			"#{klass.name}/#{resource}"
		end
		
		def read_template klass, resource
			return klass[resource]
		end
		
		def preprocess_template input, params
			if params[:preprocessing]
				input.gsub(/\$\{.+?\}/) do |term| 
					identifier = term.slice(2 .. term.size-2)
          "<%= #{identifier}.to_html if #{identifier}%>"
				end
			else
				input
			end								
		end
		
		#	def self.template_exist? klass, resource = TEMPLATE_EXTENSION
		#		# Can't use 'Module.resource_exist?' becouse it also search hierarchy.
		#		klass.resource_exist? resource 
		##		RubyExt::Resource.resource_exist? klass, resource
		#	end				
		
		def validate html, klass = nil
			begin
				return if klass == Engine::Window
				REXML::Document.new("<root>#{html}</root>")
			rescue Exception => e
				if klass
					raise_without_self "Invalid HTML for '#{klass.name}' Component:\n#{html} (#{e.message})", WGUI
				else
					raise_without_self "Invalid HTML (#{e.message})!", WGUI
				end
			end
		end
	end
end