require 'utils/import_all'
require 'spec'

module Utils
	describe "ImportAll" do
		class A
			class B; end
			class C; end
			class D; end
		end
        
		class E
			extend ImportAll
			import_all A
		end
        
		it do
			E::B
		end
	end
end