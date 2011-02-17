class Page
	inherit Entity
	
	metadata	do
		attribute :greeting, :string
		attribute :detail, :string
		child :pages, :bag
	end
end