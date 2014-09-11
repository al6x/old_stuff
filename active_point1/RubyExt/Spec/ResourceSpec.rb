require 'RubyExt/require_base'
require 'spec'
Thread.abort_on_exception=true

module RubyExt::Spec
	describe "Resource" do
		Resource = RubyExt::Resource
		
		before :all do
			dir = "#{File.dirname(__FILE__)}/ForResource/ProviderChaining"
			Resource.add_resource_provider RubyExt::FileSystemProvider.new("#{dir}/ProviderABaseDir")
    	Resource.add_resource_provider RubyExt::FileSystemProvider.new("#{dir}/ProviderBBaseDir")
		end

		it "class get, set, exist, delete" do
			Resource.class_set("RubyExt::Spec::ForResource::ClassTest",
				"class ClassTest; end")
			
			Resource.class_exist?("RubyExt::Spec::ForResource::ClassTest").
				should be_true
			
			Resource.class_get("RubyExt::Spec::ForResource::ClassTest").
				should == "class ClassTest; end"
			
			Resource.class_delete("RubyExt::Spec::ForResource::ClassTest")
			Resource.class_exist?("RubyExt::Spec::ForResource::ClassTest").
				should be_false
			
		end
		
		it "namespace" do
			Resource.class_exist?("RubyExt::Spec::ForResource").should be_true
		end

		it "resource get, set, delete, exist" do
			dir = "#{File.dirname(__FILE__)}/ForResource/ResourceTest"
			FileUtils.remove_dir(dir) if File.exist? dir

			FileUtils.mkdir dir
			File.write("#{dir}/Test.rb", "class Test; end")
			File.write("#{dir}/Test.txt", "Test.txt")
			FileUtils.mkdir "#{dir}/Test.res"
			File.write("#{dir}/Test.res/Data.txt", "Data.txt")

			Resource.resource_get(RubyExt::Spec::ForResource::ResourceTest::Test, "txt").
				should == "Test.txt"
			Resource.resource_get(RubyExt::Spec::ForResource::ResourceTest::Test, "Data.txt").
				should == "Data.txt"
			
			Resource.resource_exist?(RubyExt::Spec::ForResource::ResourceTest::Test, "txt").
				should be_true
			Resource.resource_exist?(RubyExt::Spec::ForResource::ResourceTest::Test, "Data.txt").
				should be_true

			Resource.resource_delete(RubyExt::Spec::ForResource::ResourceTest::Test, "txt")
			Resource.resource_delete(RubyExt::Spec::ForResource::ResourceTest::Test, "Data.txt")
			Resource.resource_exist?(RubyExt::Spec::ForResource::ResourceTest::Test, "txt").
				should be_false
			Resource.resource_exist?(RubyExt::Spec::ForResource::ResourceTest::Test, "Data.txt").
				should be_false


			Resource.resource_set(RubyExt::Spec::ForResource::ResourceTest::Test, "txt",
				"Test.txt")
			Resource.resource_set(RubyExt::Spec::ForResource::ResourceTest::Test, "Data.txt",
				"Data.txt")
			Resource.resource_get(RubyExt::Spec::ForResource::ResourceTest::Test, "txt").
				should == "Test.txt"
			Resource.resource_get(RubyExt::Spec::ForResource::ResourceTest::Test, "Data.txt").
				should == "Data.txt"
		end

		it "Class to Path" do
			lambda{Resource.class_to_virtual_file("A::B::C").should =~ /A\/B\/C/}.should raise_error(/doesn't exist!/)
			Resource.class_to_virtual_file("RubyExt::Spec::ForResource::ResourceTest::Test").should =~
			/RubyExt\/Spec\/ForResource\/ResourceTest\/Test/
		end

		it "change listeners" do
			classes, resources = [], []
			Resource.add_observer do |type, klass, resource|
				if type == :class
					classes << klass
				else
					classes << klass
					resources << resource
				end
			end

			begin
				Resource.start_watching(1)
			
				sleep 0.5
				base = "#{File.dirname(__FILE__)}/ForResource"
				File.write("#{base}/ChangedClass.rb", "class ChangedClass; end")
				File.write("#{base}/ChangedClass.txt", "")
				File.write("#{base}/ChangedClass.res/Text.txt", "")
				sleep 1.5
			ensure
				Resource.stop_watching
			end

			classes.size.should == 3
			classes.all?{|k| k == ForResource::ChangedClass}.should be_true

			resources.size.should == 2
			resources.should include("txt")
			resources.should include("Text.txt")
		end
		
		it "ResourceProvider Chaining" do			    	        	
    	Resource.class_get("ChainTest").should == %{\
class ChainTest; 	
# "ProviderB"
end}
			Resource.resource_get(ChainTest, "resource").should == "ProviderB"		
    end

    it "ResourceExtension" do
      require 'RubyExt/require'
      Resource.resource_set RubyExt::Spec::ForResource::ResourceExtension, "Data.yaml", {:value => true}
      res = Resource.resource_get RubyExt::Spec::ForResource::ResourceExtension, "Data.yaml"
      res.should == {:value => true}
    end        
	end
end