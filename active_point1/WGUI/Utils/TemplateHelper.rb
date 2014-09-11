class TemplateHelper				
	extend Log
	
	class WGUIERuby < Erubis::Eruby
		#		def escaped_expr code
		#			return code
		#		end
	end		
	
	class << self
		attr_accessor :custom_template
		
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
				
				input = if custom_template
					custom_template.call(klass, resource) || klass[resource]
				else
					klass[resource]
				end
				
				# Preprocessing
				if params[:preprocessing]
					input.gsub!(/\$\{.+?\}/) do |term| 
						identifier = term.slice(2 .. term.size-2)
          "<%= #{identifier}.to_html if #{identifier}%>"
					end
				end
				
				# Binding
				bind = params[:binding] || binding
				
				# Process Template
				html = WGUIERuby.new(input).result(bind)
				
				validate(html, klass) if $debug
				
				return html 
			rescue Exception => e
				log.error "Error by rendering template '#{resource}' for '#{klass.name}' Class!"
				raise e
			end
		end				
		
		#	def self.template_exist? klass, resource = TEMPLATE_EXTENSION
		#		# Can't use 'Module.resource_exist?' becouse it also search hierarchy.
		#		klass.resource_exist? resource 
		##		RubyExt::Resource.resource_exist? klass, resource
		#	end				
		
		def validate html, klass
			begin
				REXML::Document.new("<root>#{html}</root>")
			rescue Exception => e
				raise_without_self "Invalid HTML for '#{klass.name}' Component:\n#{html} (#{e.message})", WGUI
			end
		end
	end
end