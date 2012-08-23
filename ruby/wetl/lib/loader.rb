class ETL::Loader < ETL::Base
  attr_accessor :base, :options, :transformer, :extractor, :loading
  
  def initialize base, extractor, transformer, opt = {}, &loading
    self.base = base.should_not! :be_nil
    self.extractor = extractor.should_not!(:be_nil)
    self.transformer = transformer.should_not!(:be_nil)
    self.options = opt.to_openobject
    self.loading = loading

    prepare
  end
    
  def each_object &block
    while obj = transformer.objects.find_one({:error => {:$exists => false}, :loaded => {:$exists => false}}, {})
      obj = obj.to_openobject      
      
      begin
        block.call obj    
      rescue Exception => e        
        obj['load_error'] = e.message
        p "Can't load Object: #{e.message} (#{obj.url})"
      end
      
      obj['loaded'] = true
      transformer.objects.save obj

      print_info
    end      
  end
  
  def print_info
    loaded = transformer.objects.find({:error => {:$exists => false}, :loaded => {:$exists => true}}).count
    p "Loaded: #{loaded}, Total: #{transformer.objects.find(:error => {:$exists => false}).count}"
  end
  
  def clear
    transformer.objects.find({:loaded => true}, {}).each do |obj|      
      obj.delete 'loaded'
      obj.delete 'load_error'
      transformer.objects.save obj
    end
  end
  
  def run
    if options.clear?
      clear
      prepare
    end
    
    loading.call self
  end
  
  protected
    def prepare
      self.transformer.objects.create_index 'loaded', false
    end
end