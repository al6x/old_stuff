class Initializer
	def initialize_storage storage
		MicroContainer::ScopeManager.activate_thread :initializer do     
			DomainModel::Transactional.transaction{
				run storage
			}
			DomainModel::Transactional.commit
		end    		
	end
	
	protected
	RTData = WGUIExt::RichText::RTData
	Uploader = WebClient::Engine::WGUIAdapters::ResourceHelper
	def run storage				
		text = get_text
		
		dir = "./DomainLibrary/Portal/data/sample/images"
		
		# Content
		# Images
		ibuilding = Uploader.upload_from_file storage, "#{dir}/building.jpg"
		ispyder = Uploader.upload_from_file storage, "#{dir}/lamborghini_spyder.jpg"
		imrear = Uploader.upload_from_file storage, "#{dir}/Mazda rear.jpg"
		imrx7 = Uploader.upload_from_file storage, "#{dir}/RX-7.jpg"
		
		
		# Text		
		croot = storage.root.copy
		croot.site = site = Content.new.set(:name => "Site", :text => RTData.new(text[:site], [ispyder, imrear, imrx7]))
		site.pages << pabout = Content.new.set(:name => "About", :text => RTData.new(text[:about], [ibuilding]))
		site.pages << pproducts = Content.new.set(:name => "Products", :text => RTData.new("Some text, bla-bla"))
		pproducts.pages << pspyder = Content.new.set(:name => "Lamborgini Spyder", :text => RTData.new(text[:spyder], [ispyder]))
		pproducts.pages << pmrear = Content.new.set(:name => "Mazda Rear", :text => RTData.new(text[:rear], [imrear]))
		pproducts.pages << pmrx7 = Content.new.set(:name => "Mazda RX-7", :text => RTData.new(text[:rx7], [imrx7]))		
		site.pages << pservices = Content.new.set(:name => "Services", :text => RTData.new("Some text, bla-bla"))
		pservices.pages << presearch = Content.new.set(:name => "Research", :text => RTData.new("Some text, bla-bla"))
		pservices.pages << pdevelopment = Content.new.set(:name => "Development", :text => RTData.new("Some text, bla-bla"))
		pservices.pages << penergy = Content.new.set(:name => "Energy", :text => RTData.new("Some text, bla-bla"))
		
		# Tools
		ctools = storage.root.core.tools.copy
		ctools.tools << news = Tools::News.new.set(:name => "News")
		ctools.tools << tree_menu = Tools::TreeMenu.new.set(:name => "TreeMenu")
		tree_menu.menu = menu = Tools::TreeMenu::Item.new.set(:name => "Menu")
		menu.items << Tools::TreeMenu::Item.new.set(:name => "About", :link => pabout)
		menu.items << mproducts = Tools::TreeMenu::Item.new.set(:name => "Products", :link => pproducts)
		mproducts.items << Tools::TreeMenu::Item.new.set(:name => "Lamborgini Spyder", :link => pspyder)
		mproducts.items << Tools::TreeMenu::Item.new.set(:name => "Mazda Rear", :link => pmrear)
		mproducts.items << Tools::TreeMenu::Item.new.set(:name => "Mazda RX-7", :link => pmrx7)
		menu.items << mservices = Tools::TreeMenu::Item.new.set(:name => "Services", :link => pservices)
		mservices.items << Tools::TreeMenu::Item.new.set(:name => "Research", :link => presearch)
		mservices.items << Tools::TreeMenu::Item.new.set(:name => "Development", :link => pdevelopment)
		mservices.items << Tools::TreeMenu::Item.new.set(:name => "Energy", :link => penergy)
		
		# TopRight Content
		ctools.tools << topright_content = Tools::Content.new.set(:name => "TopRight Content", :content => text[:top_right])
		
		# Right Content
		ctools.tools << right_content = Tools::Content.new.set(:name => "Right Content", :content2 => RTData.new(text[:right], [ispyder, imrear, imrx7]))
		
		# Layout
		clayouts = storage["Home/Core/Layouts"].copy		
		clayouts.layouts << layout = DomainModel::Core::Layouts::Border.new.set(:name => "Site Layout")
		
		layout.left_tools << storage["Home/Core/Tools/Logo"]
		layout.left_tools << tree_menu		
		layout.left_tools << news
		
		layout.center_tools << storage["Home/Core/Tools/ObjectView"]
		
		layout.top_container = :flow
		layout.top_tools << storage["Home/Core/Tools/Breadcrumb"]
		layout.top_tools << topright_content				
		
		layout.right_tools << right_content					
		
		site.layout = layout
		
		# News
		news.news << Tools::News::Item.new.set(:name => "First Site!", :link => site, :text => "Our first site\nHas been created!")
		news.news << Tools::News::Item.new.set(:name => "Lamborgini", :link => pspyder, :text => "New Model from\nfamous Lamborgini family.\nDon't miss it!")
		news.news << Tools::News::Item.new.set(:name => "Energy Sources", :link => penergy, :text => "Tremedeous improving in\nplazma fuel cell has\nbeen reached!")
	end
	
	def get_text
		{
			:about => %{\
<p>
    MinGine - the world leader company! We are the Best!
</p>
<p>
    This is our Main Office:
</p>
<p>
    <img title="building" src="__res__/building" mce_src="__res__/building" alt="building" width="171" height="259"/>
</p>
<p>
    So, do not fuck with us!
</p>},

			:site => %{\
<p>
    <h1>Fastest Cars Ever! Runs with the Speed of Light!</h1>
</p>
<p>
    <a href="?o=Home/Site/Products/Lamborgini Spyder" mce_href="?o=Home/Site/Products/Lamborgini Spyder">
        <img title="lamborghini_spyder" src="__res__/lamborghini_spyder" alt="lamborghini_spyder" mce_src="__res__/lamborghini_spyder" width="100"/>
    </a>
    <a href="?o=Home/Site/Products/Mazda Rear" mce_href="?o=Home/Site/Products/Mazda Rear">
        <img title="Mazda rear" src="__res__/Mazda rear" alt="Mazda rear" mce_src="__res__/Mazda rear" width="100"/>
    </a>
    <a href="?o=Home/Site/Products/Mazda RX-7" mce_href="?o=Home/Site/Products/Mazda RX-7">
        <img title="RX-7" src="__res__/RX-7" alt="RX-7" mce_src="__res__/RX-7" width="100"/>
    </a>
</p>
<p>
    Contact our managers for prices ...
</p>},

			:spyder => %{\
<p>
    Look at it ...
</p>
<p>
    <img title="lamborghini_spyder" src="__res__/lamborghini_spyder" mce_src="__res__/lamborghini_spyder" alt="lamborghini_spyder" width="400"/>
</p>},

			:rear => %{\
<p>
    Look at it ...
</p>
<p>
    <img title="Mazda rear" src="__res__/Mazda rear" mce_src="__res__/Mazda rear" alt="Mazda rear" width="400"/>
</p>},

			:rx7 => %{\
<p>
    Look at it ...
</p>
<p>
    <img title="RX-7" src="__res__/RX-7" mce_src="__res__/RX-7" alt="RX-7" width="400"/>
</p>},		
			
			:right => %{\
<table class="general_container container_padding" style="" border="0">
    <tbody>
        <tr>
            <td>
                <a href="?o=Home/Site/Products/Lamborgini Spyder" mce_href="?o=Home/Site/Products/Lamborgini Spyder">
                    <img title="lamborghini_spyder" src="__res__/lamborghini_spyder" alt="lamborghini_spyder" mce_src="__res__/lamborghini_spyder" width="100"/>
                </a>
            </td>
            <td>
                Want to know more?
            </td>
        </tr>
        <tr>
            <td>
                <a href="?o=Home/Site/Products/Mazda Rear" mce_href="?o=Home/Site/Products/Mazda Rear">
                    <img title="Mazda rear" src="__res__/Mazda rear" alt="Mazda rear" mce_src="__res__/Mazda rear" width="100"/>
                </a>
            </td>
            <td>
                Try it!
            </td>
        </tr>
        <tr>
            <td>
                <a href="?o=Home/Site/Products/Mazda RX-7" mce_href="?o=Home/Site/Products/Mazda RX-7">
                    <img title="RX-7" src="__res__/RX-7" alt="RX-7" mce_src="__res__/RX-7" width="100"/>
                </a>
            </td>
            <td>
                Enjoy!
            </td>
        </tr>
    </tbody>
</table>},
			
			:top_right => %{\
<table class="general_container container_padding"><tbody>
	<tr>
		<td style="vertical-align:center; text-align: right;">
			<a href="?o=Home/Site/About">About</a> | <a href="?o=Home/Site/Products">Products</a> | <a href="?o=Home/Site/Services">Services</a>
		</td>
		<td style="vertical-align:center; text-align: right;">
			<a href="#" onclick="alert('Not implemented!')">Login</a>
		</td>
	</tr>
</tbody></table>}
		}
	end
end