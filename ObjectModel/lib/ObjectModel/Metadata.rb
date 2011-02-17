class Metadata 
	ATTRIBUTE_TYPES_SHORTCUTS = self["attribute_types_shortcuts.rb"]
	CHILD_TYPES_SHORTCUTS = self["child_types_shortcuts.rb"]
	REFERENCE_TYPES_SHORTCUTS = self["reference_types_shortcuts.rb"]
	
	BEFORE_EVENT_TYPES = self["before_event_types.rb"]
	AFTER_EVENT_TYPES = self["after_event_types.rb"]
	
	attr_accessor :klass
	
	def initialize klass
		super()
		@klass = klass
		Metadata.definition.each do |name, defn|
			send name.to_writer, defn.initial_value(@klass)
		end
	end
	
	def inherit parent
		new = Metadata.new klass
		Metadata.definition.each do |name, defn|
			pmeta = parent.send name
			cmeta = self.send name
			new.send name.to_writer, defn.inherit(pmeta, cmeta)
		end
		return new
	end		
	
	class << self		
		def definition
			@definition ||= {}
		end
	end
end