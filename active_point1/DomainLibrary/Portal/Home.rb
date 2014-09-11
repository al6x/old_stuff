class Home
	inherit OGDomain:: Entity
	include DomainModel::Core::Layouts::Layout
	
	build_dmeta do |m|
		m.entity_name "Home"
		
		m.attribute :name, :string, "Name", :initialize => "Home"
		
		m.attribute :core, :entity, "Core"
		
		m.attribute :site, :entity, "Site"
		
    m.operation :on_edit, :edit_properties, "Update Properties",  :attributes => [:name, :root_name]
    
    m.children :core, :site
	end
	
	build_vmeta do |m|
		m.action :on_view, :view, :form => View
		
		m.action :on_edit, :edit_properties, :title => "Edit", :form => EditProperties		
	end
end