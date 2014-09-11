require 'state_machine'
class Vehicle
	attr_accessor :seatbelt_on
	
	state_machine :state, :initial => :parked do
		before_transition :from => [:parked, :idling], :do => :put_on_seatbelt
		after_transition :on => :crash, :do => :tow
		after_transition :on => :repair, :do => :fix
		after_transition :to => :parked do |vehicle, transition|
			vehicle.seatbelt_on = false
		end
		
		event :park do
			transition :to => :parked, :from => [:idling, :first_gear]
		end
		
		event :ignite do
			transition :to => :stalled, :from => :stalled
			transition :to => :idling, :from => :parked
		end
		
		event :idle do
			transition :to => :idling, :from => :first_gear
		end
		
		event :shift_up do
			transition :to => :first_gear, :from => :idling
			transition :to => :second_gear, :from => :first_gear
			transition :to => :third_gear, :from => :second_gear
		end
		
		event :shift_down do
			transition :to => :second_gear, :from => :third_gear
			transition :to => :first_gear, :from => :second_gear
		end
		
		event :crash do
			transition :to => :stalled, :from => [:first_gear, :second_gear, :third_gear], :unless => :auto_shop_busy?
		end
		
		event :repair do
			transition :to => :parked, :from => :stalled, :if => :auto_shop_busy?
		end
		
		state :parked do
			def speed
				0
			end
		end
		
		state :idling, :first_gear do
			def speed
				10
			end
		end
		
		state :second_gear do
			def speed
				20
			end
		end
	end
	
	state_machine :hood_state, :initial => :closed, :namespace => 'hood' do
		event :open do
			transition :to => :opened
		end
		
		event :close do
			transition :to => :closed
		end
		
		state :opened, :value => 1
		state :closed, :value => 0
	end
	
	def initialize
		@seatbelt_on = false
		super() # NOTE: This *must* be called, otherwise states won't get initialized
	end
	
	def put_on_seatbelt
		@seatbelt_on = true
	end
	
	def auto_shop_busy?
		false
	end
	
	def tow
		# tow the vehicle
	end
	
	def fix
		# get the vehicle fixed by a mechanic
	end
end
v = Vehicle.new
v.ignite
p v.state
v.class.instance_variable_get("@state_machines")[:state].draw(
:name => "sm", :output => true,
:orientation => "landscape")