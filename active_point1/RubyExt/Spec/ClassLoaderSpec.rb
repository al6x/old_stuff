require 'RubyExt/require_base'
require 'spec'

module RubyExt::Spec
	describe "PackageManager" do
		it "Should load classes only one" do
			list = []
			RubyExt::ClassLoader.add_observer{|klass| list << klass}
			ForClassLoader::LoadCount
			ForClassLoader::LoadCount
			RubyExt::ClassLoader.delete_observers
			list.inject(0){|count, klass| klass == ForClassLoader::LoadCount ? count + 1 : count}.
				should == 1
		end

		it "Class has the same name as package" do
			ForClassLoader::ModuleA::SameName
			RubyExt::Spec::ForClassLoader::ModuleA::SameName::SomeClass
		end

		it "Infinity Loop" do
			lambda{ForClassLoader::ModuleA::InfinityLoop}.
				should raise_error(/Class Name .+ doesn't correspond to File Name/)
		end

		it "Core" do
			ForClassLoader::ModuleA::ModuleB::ClassC.new
		end


		module ForClassLoader::ModuleA
			class << self
        def anonymous
					ClassInsideAnonymousClass
        end
			end
		end

		it "Should works inside Anonymous Class" do
			ForClassLoader::ModuleA.anonymous
		end

		it "Should raise exception if class isn't defined in scope" do
			ForClassLoader::Scope::ScopeA1
			RubyExt::ClassLoader.error_on_defined_constant = true
			lambda{ForClassLoader::Scope::ScopeB1}.
				should raise_error(/Class '.+' is not defined in the '.+' Namespace!/)
		end

		it "Class Reloading" do
			fname = File.join(File.dirname(__FILE__), 'ForClassLoader/ModuleA/ClassReloading.rb')
			File.delete fname if File.exist? fname
			File.open(fname, 'w') do |f|
				f.write %{\
class ClassReloading
	def test
		1
	end
end}
			end

			test = ForClassLoader::ModuleA::ClassReloading.new
			test.test.should == 1

			File.open(fname, 'w') do |f|
				f.write %{\
class ClassReloading
	def test
		2
	end
end}
			end

			RubyExt::ClassLoader.reload_class(ForClassLoader::ModuleA::ClassReloading.name)
			test.test.should == 2

			File.delete fname if File.exist? fname
		end
	end
end