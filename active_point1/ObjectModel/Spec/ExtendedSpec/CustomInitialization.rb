class CustomInitialization
	inherit Entity
	metadata do
		attribute :string, :string, :initialize => lambda{|e| e.entity_id}
		attribute :number, :number, :initialize => 1
		attribute :boolean, :boolean, :initialize => true
		attribute :object, :object, :initialize => 45
		attribute :data, :data, :initialize => lambda{|e| StreamID.new("sid")}
		attribute :date, :date, :initialize => DateTime.new(2009, 1, 1)
	end					
end