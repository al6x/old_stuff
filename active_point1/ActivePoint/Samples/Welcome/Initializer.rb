class Initializer
	def check_and_initialize
		unless R.include? "Welcome"
			R.transaction(Transaction.new){
				Model::Page.new("Welcome").set \
				:greeting => "Welcome a board",
				:detail => "You are on ActivePoint!"
			}.commit
		end
	end
end