require 'RubyExt/require'
require 'spec'

module RubyExt::Spec
	describe 'Cache' do
		class CachedClass
			attr_accessor :value
			def value_get; @value end
			
			attr_accessor :value2
			def value2_get; @value2 end
			
			attr_accessor :params
			def params_get param; @params[param] end 				
		end						
		
		Cache.cached CachedClass, CachedClass, :value_get
		Cache.cached :cache_version_name, CachedClass, :value2_get
		Cache.cached_with_params CachedClass, CachedClass, :params_get
		
		it "Simple Cache" do
			o = CachedClass.new
			o.value = 0
			o.value2 = 0
			o.value_get.should == 0
			o.value2_get.should == 0
			o.value = 1
			o.value2 = 1
			o.value_get.should == 0
			o.value2_get.should == 0
			Cache.update CachedClass
			o.value_get.should == 1
			o.value2_get.should == 0
			Cache.update :cache_version_name
			o.value2_get.should == 1
			Cache.update CachedClass, :cache_version_name
		end
		
		it "Cache With Params" do
			o = CachedClass.new
			o.params = {:a => :b}
			o.params_get(:a).should == :b
			o.params = {:a => :c}
			o.params_get(:a).should == :b
			Cache.update CachedClass
			o.params_get(:a).should == :c
		end
		
		class CachedClass2
			class << self
				attr_accessor :value
				def value_get; @value end 								
			end
		end				
		
		Cache.cached CachedClass2, CachedClass2.singleton_class, :value_get				
		
		it "Simple Cache" do
			CachedClass2.value = 0
			CachedClass2.value_get.should == 0
			CachedClass2.value = 1
			CachedClass2.value_get.should == 0
			Cache.update CachedClass2
			CachedClass2.value_get.should == 1
		end
		
		class MultipleCacheVersions
			attr_accessor :value
			def value_get; @value end 								
				
			attr_accessor :value2
			def value2_get params; @value2 end
		end
		
		Cache.cached [:class, :resource_update, :security_update], MultipleCacheVersions, :value_get				
		Cache.cached_with_params [:class, :resource_update, :security_update], MultipleCacheVersions, :value2_get				
		
		it "Multiple cache versions" do
			o = MultipleCacheVersions.new
			o.value, o.value2 = 0, 0
			
			o.value_get.should == 0
			o.value = 1
			o.value_get.should == 0			
			Cache.update :class
			o.value_get.should == 1
			o.value = 2
			o.value_get.should == 1
			Cache.update :resource_update, :security_update
			o.value_get.should == 2
			
			o.value2_get("params").should == 0
		end
	end
end