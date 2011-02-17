class SampleData	
	RichText = WGUIExt::Editors::RichTextData
	Uploader = WGUIExt::Editors::WGUIAdapters::ResourceHelper
	
	def self.install
		SampleData.new.install
	end
	
	def install
		R.transaction(Transaction.new){
			@dir = "#{File.dirname __FILE__}/SampleData.res/images"
			
			fill_wigets		
			home_layout, general_layout, full_layout = fill_layouts
			site = fill_site general_layout
			fill_pages site, home_layout, full_layout
			fill_blog site	
			security = R.by_id "Security"	
			users = R.by_id "Users"	
			site_managers = fill_users users
			fill_security site, security, site_managers				
		}.commit
	end
	
	protected 
	def fill_users users
		site_managers = C::Model::Group.new "Site Managers"
		users.groups << site_managers
		
		vint = C::Model::User.new "Vint"
		site_managers.add_user vint
		users.users << vint		
		
		return site_managers
	end
	
	def fill_security site, security, site_managers
		site_managers = site_managers.entity_id
		
		viewer = R.by_id("Security")["Viewer"]
		editor = R.by_id("Security")["Editor"]
		manager = R.by_id("Security")["Manager"]
		anonymous_group = C::Model::Group::ANONYMOUS
		
		site_policy = C::Model::Policy.new "Site Policy"
		site_policy.map = {
			viewer.entity_id => {anonymous_group => true, site_managers => true},
			editor.entity_id => {site_managers => true},
			manager.entity_id => {site_managers => true}
		}		
		
		security.policies << site_policy
		site.set_policy site_policy
	end
	
	def fill_wigets
		appearance = R.by_id("Appearance")
		banners = self.class["banners.rb"]
		
		# Banner Left
		site_banner_left = C::Model::Wiget.new "Site Banner Left"
		site_banner_left.wiget_class = Portal::Wigets::TextArea
		site_banner_left.storage = {
			:title => nil,
			:content => RichText.new(banners[0])
		}
		appearance.wigets << site_banner_left
		
		# Banner Right
		site_banner_right = C::Model::Wiget.new "Site Banner Right"
		site_banner_right.wiget_class = Portal::Wigets::TextArea
		site_banner_right.storage = {
			:title => "WHAT OUR CLIENTS SAY",
			:content => RichText.new(banners[1])
		}
		appearance.wigets << site_banner_right
		
		# Banner Right
		site_banner_side = C::Model::Wiget.new "Site Banner Sidebar"
		site_banner_side.wiget_class = Portal::Wigets::TextArea
		site_banner_side.storage = {
			:title => "GOT <span>A QUESTION?</span>",
			:content => RichText.new(banners[2])
		}
		appearance.wigets << site_banner_side
		
		# News
		site_news = C::Model::Wiget.new "Site News"
		site_news.wiget_class = Portal::Wigets::News
		site_news.parameters = {:path => "Portal/Site/Blog", :title => "NEWS", :content_accessor => :details}				
		appearance.wigets << site_news
	end
	
	def fill_layouts
		appearance = R.by_id("Appearance")
		
		# Home Layout
		home_layout = ActivePoint::Plugins::Appearance::Model::Layouts::CustomLayout.new "Site Home Layout"
		home_layout.layout_class = Site::Wigets::SiteLayout
		home_layout.parameters = {
			:map => {
				:menu => "Portal/Core/Appearance/Site Menu",
				:user_menu => "Portal/Core/Appearance/User Menu",
				:messages => "Portal/Core/Appearance/Messages"
			},			 			
			:right => [
			"Portal/Core/Appearance/Site Banner Left", 
			"Portal/Core/Appearance/Site Banner Right",
			],
			:left => ["Portal/Core/Appearance/Site News"], 			
		}				
		appearance.layouts << home_layout
		
		# General Layout
		site_general_layout = ActivePoint::Plugins::Appearance::Model::Layouts::CustomLayout.new "Site General Layout"
		site_general_layout.layout_class = Site::Wigets::SiteLayout
		site_general_layout.parameters = {
			:map => {
				:menu => "Portal/Core/Appearance/Site Menu",
				:user_menu => "Portal/Core/Appearance/User Menu",
				:messages => "Portal/Core/Appearance/Messages"
			},			
			:left => [
			"Portal/Core/Appearance/Site Banner Sidebar", 
			"Portal/Core/Appearance/Site News"
			], 
		}				
		appearance.layouts << site_general_layout
		
		# Full Layout
		site_full_layout = ActivePoint::Plugins::Appearance::Model::Layouts::CustomLayout.new "Site Full Layout"
		site_full_layout.layout_class = Site::Wigets::SiteLayout
		site_full_layout.parameters = {
			:map => {
				:menu => "Portal/Core/Appearance/Site Menu",
				:user_menu => "Portal/Core/Appearance/User Menu",
				:messages => "Portal/Core/Appearance/Messages"
			},
		}											
		appearance.layouts << site_full_layout		
		
		return home_layout, site_general_layout, site_full_layout
	end
	
	def fill_site site_general_layout
		site = Model::Site.new "Site"
		site.wc_layout = site_general_layout
		site.wc_skin = "Aqueous"
		site.set! \
		:logo => "COMPANY NAME", 
		:description => "LOREM IPSUM SIT DOLOR AMET", 
		:footer => "<p>Copyright &copy; 2008 COMPANY NAME <br /> All Rights Reserved.</p>"
#		:menu => ""
		R.by_id("Portal").items << site		
		return site				
	end
	
	def fill_pages site, home_layout, full_layout		
		img = Uploader.upload_from_file R, "#{@dir}/servers.jpg"
		page = Model::SitePage.new("Home").set! \
		:title => "WELCOME TO COMPANY NAME",		
		:content => RichText.new(self.class["page_home.txt"], [img]), 
		:wc_layout => home_layout
		site.items << page
		
		img = Uploader.upload_from_file R, "#{@dir}/crysis.jpg"
		page = Model::SitePage.new("About").set! \
		:title => "ABOUT COMPANY NAME",		
		:content => RichText.new(self.class["page_about.txt"], [img])
		site.items << page
		
		page = Model::SitePage.new("Services").set! \
		:title => "SERVICES WE OFFER",		
		:content => RichText.new(self.class["page_services.txt"]), 
		:wc_layout => full_layout
		site.items << page				
	end
	
	def fill_blog site
		# Blog
		blog = Blog::Model::Blog.new("Blog").set! :sorting_order => "Latest"
		site.items << blog
		
		user = R.by_id(C::Model::User::ANONYMOUS)				
		
		# Post 1
		img = Uploader.upload_from_file R, "#{@dir}/vault.jpg"
		data = self.class["post_1.rb"]
		post = Blog::Model::Post.new.set! \
		:title => "FAQs FREQUENTLY ASKED QUESTIONS",
		:details => data[:details],
		:content => RichText.new(data[:content]),
		:icon => img,
		:author => user
		blog.posts << post
		
		# Post 2
		img = Uploader.upload_from_file R, "#{@dir}/weapon.jpg"
		data = self.class["post_2.rb"]
		post = Blog::Model::Post.new.set! \
		:title => "WHAT OUR CLIENTS SAY",
		:details => data[:details],
		:content => RichText.new(data[:content]),
		:icon => img,
		:author => user
		
		comment = Blog::Model::Comment.new.set! \
		:content => RichText.new(data[:comment1]),
		:author => user
		post.comments << comment
		
		comment = Blog::Model::Comment.new.set! :\
		content => RichText.new(data[:comment2]),
		:author => user
		post.comments << comment
		
		blog.posts << post				
	end
end