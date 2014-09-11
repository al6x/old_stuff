require 'RubyExt/require_base'
require 'spec'

module RubyExt::Spec1
	describe "ImportAll" do
		class A
			class B; end
			class C; end
			class D; end
		end

		class E
			extend RubyExt::ImportAll
			import_all A
		end

		it do
			E::B
		end
	end
end