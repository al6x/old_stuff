require 'ActivePoint/require'
require 'spec'

module ActivePoint
	module EngineSpec
		describe "Engine" do
			it "sort_dependencies" do
				module PlugA
					class Config
						extend Configurator
					end		
				end
				
				module PlugB
					extend Configurator
					depends_on PlugA
				end
				
				module PlugC
					class Config
						extend Configurator
						depends_on PlugA, PlugB 
					end		
				end				
				
				sorted = Engine::Extensions.send :sort_dependencies, [PlugB, PlugA, PlugC]
				sorted.should == [PlugA::Config, PlugB, PlugC::Config]
			end
			
			it "sort_dependencies should report circular dependencies" do
				
				module PlugCA
					class Config
						extend Configurator
					end		
				end
				
				module PlugCB
					class Config
						extend Configurator
						depends_on PlugCA
					end		
				end				
				
				PlugCA::Config.depends_on PlugCB
				
				lambda{
					Engine::Extensions.send :sort_dependencies, [PlugCA, PlugCB]
				}.should raise_error(/Circular/)
			end
		end
	end
end