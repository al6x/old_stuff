class Initializer
	def check_and_initialize
		unless R.include? "Page"
			R.transaction(Transaction.new){
				Model::Page.new("Page", "Page")
			}.commit
		end		
	end
end