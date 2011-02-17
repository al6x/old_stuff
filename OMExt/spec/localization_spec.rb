require 'OMExt/require'
require 'spec'

module ObjectModel
	module LocalizationSpec
		describe "Localization" do	
			class LocalizedEntity
				inherit Entity, OMExt::Locale
				
				metadata do 
					attribute :string, :locale, :parameters => {:type => :string}
					attribute :richtext, :locale, :parameters => {:type => :richtext}
				end
				locale :string, :richtext							
			end	   
			
			before :all do
				RubyExt::Localization.default_language = :en
				RubyExt::Localization.language = lambda{:en}
			end
			
			it "Basic" do					
				@r.transaction{
					le = LocalizedEntity.new "le"
					le.string.should == ""
					le.string = "English"
					le.string.should == "English"
				}.commit					
				@r["le"].string.should == "English"
				
				@r.transaction{
					le = @r['le']
					le.string.should == "English"
					le.string = "English2"
				}.commit					
				@r["le"].string.should == "English2"					
			end
			
			it "Language switching (should use default Language if not defined)" do
				@r.transaction{
					le = LocalizedEntity.new "le"
					le.string.should == "" # <= Shold return initial value
					le.string = "English"
					le.string.should == "English"
					
					RubyExt::Localization.language = lambda{:ru}
					le.string.should == "English" # <= Should return value from default language
					le.string = "Russian"
					le.string.should == "Russian"
					
					RubyExt::Localization.language = lambda{:en}
					le.string.should == "English"
				}.commit									
			end
			
			it "Initialization" do
				@r.transaction{
					le = LocalizedEntity.new "le"
					le.richtext.should be_a(WGUIExt::Editors::RichTextData)
				}.commit					
			end
			
			it "Explicit Language" do
				@r.transaction{
					le = LocalizedEntity.new "le"
					RubyExt::Localization.language = lambda{:en}						
					le.string = "English"
					RubyExt::Localization.language = lambda{:ru}						
					le.string = "Russian"
					RubyExt::Localization.language = lambda{:en}						
					
					le.string.should == "English"
					OMExt::Locale.language :ru do
						le.string.should == "Russian"
					end
					le.string.should == "English"
				}.commit
			end
			
			before :each do
				CONFIG[:directory] = "#{File.dirname __FILE__}/data"
				Repository.delete :test
				@r = Repository.new :test
			end
			
			after :each do
				@r.close
				Repository.delete :test
			end
		end
	end
end