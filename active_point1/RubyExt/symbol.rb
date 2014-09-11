class Symbol
  def <=> other
    self.to_s <=> other.to_s
  end
  
  def to_reader
    self
  end
  
  def to_writer
		"#{self}=".to_sym
	end
 
 	def to_iv
		"@#{self}"
	end

  def + other
    (self.to_s + other.to_s).to_sym
  end
end