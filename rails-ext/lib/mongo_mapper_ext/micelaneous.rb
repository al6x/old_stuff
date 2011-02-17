Mongo::Collection.class_eval do
  def upsert id, opt
    opt.size.should! :==, 1
    opt.should! :be_a, Hash
    opt.values.first.should! :be_a, Hash
    
    update({:_id => id}, opt, {:upsert => true, :safe => true})
  end
end