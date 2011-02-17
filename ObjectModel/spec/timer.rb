class Timer
	def initialize; @start = Time.new end
	
	def time; (Time.new - @start).round end
end