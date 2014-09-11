class Initializer
	def check_and_initialize
		unless R.include? "Blog"
			R.transaction(Transaction.new){
				Model::Blog.new("Blog", "Blog").set :title => "Blog"
			}.commit
		end		
	end
end