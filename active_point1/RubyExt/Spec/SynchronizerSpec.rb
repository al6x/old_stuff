require 'RubyExt/require'
require 'spec'

module RubyExt
	module Spec
		describe "Synchronize" do
			it "synchronize" do
				class Account
					inherit RubyExt::Synchronizer
					attr_reader :from, :to
					
					def initialize
						super
						@from, @to = 0, 0
					end
					
					def transfer
						@from -= 1
						@to += 1
					end
					synchronize :transfer
				end
				
				a, threads = Account.new, []
				100.times do 
					t = Thread.new do
						100.times{a.transfer}
					end
					threads << t
				end				
				threads.each{|t| t.join}
				
				a.from.should == -10_000
				a.to.should == 10_000
			end
		end
	end
end