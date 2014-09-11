class APController
	extend Managed
	scope :session
	
	inject :workspace => Workspace	
	
	include Observable
	
	def object= object
		Scope.delete_observers
		notify_observers :before_object_set, object
		
		object.should! :be_a, Entity
		return if @om_id == object.om_id
		
		APController.check_plugin_enabled_for object.class
		
		if workspace.include? object
			workspace.restore_scopes_for object
		else
			Scope.group(:object).begin
			Scope[:object] = object.om_id
		end		
		
		@om_id = object.om_id
		
		notify_observers :after_object_set, object
	end  		
	
	def object
		om_id = Scope[:object]
		om_id ? R.by_id(om_id) : nil
	end
	
	protected		
	class << self
		def check_plugin_enabled_for klass
			list = CORE_PLUGINS + CONFIG[:plugins]
			klass.each_namespace do |ns|
				return if list.any?{|plugin_klass| plugin_klass == ns}
			end
			raise "Plugin for Model '#{klass}' not enabled!"
		end
	end
end