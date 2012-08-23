# :link => "http://membrana.ru/lenta/?10155"
# :link => "http://membrana.ru/articles/health/2001/12/14/202500.html?wire=mainsection"
# :link => "http://membrana.ru/lenta/?10109"

class ETL::Transformer
  attr_accessor :base, :options, :extractor, :objects, :transformation
  
  def initialize base, extractor, opt = {}, &transformation
    self.base = base.should_not! :be_nil
    self.extractor = extractor.should_not!(:be_nil)
    self.options = opt.to_openobject
    self.transformation = transformation

    prepare
  end  
  
  def convert_pages_to_objects method = nil, &block
    extractor.pages.find({:transformed => nil}, {}).each_with_index do |page_obj, index|            
      page = page_obj.to_openobject
      
      begin
        objs = if method
          send method, page
        else          
          block.call page    
        end
        objs.should! :be_a, Array
        
        objs.each do |o|
          
          o.page_url = page.url
          o.version = 0
          objects.save o
        end
      rescue Exception => e
        page_obj['transformation_error'] = e.message
        p "Can't transform Page: #{e.message} (#{page.url})"
      end
      
      print_info if index % 10 == 0
      
      page_obj['transformed'] = true
      extractor.pages.save page_obj
    end      
    print_info
  end
    
  def reset_objects_version_to version
    objects.find.each_with_index do |obj, index|
      obj['version'] = version
      objects.save obj
      
      print_update_info_for version if index % 10 == 0
    end
    print_info
  end
  
  def update_objects_to version, method = nil, &block
    if objects.find(:version => {:$lt => version - 1}, :error => {:$exists => false}).count > 0
      raise "Can't migrate, some objects doesn't have previous migration! Run previous migration (version #{version - 1}) first!"  
    end

    objects.find({:version => version - 1, :error => {:$exists => false}}, {}).each_with_index do |obj, index|
      obj = obj.to_openobject
      
      begin
        objs = if method
          send method, obj
        else
          block.call obj
        end
        objs.should! :be_a, Array
        
        objs.each do |o|
          o.version = version
          objects.save o
        end
        
        objects.remove :_id => obj['_id'] unless objs.any?{|o| o['_id'] == obj['_id']}
      rescue Exception => e
        obj['error'] = e.message
        objects.save obj
        p "Can't update Object to #{version} version: #{e.message} (#{obj.page_url})"
      end
      
      print_update_info_for version if index % 100 == 0
    end
    print_info
  end
  
  def print_info
    p "Objects: #{objects.count}, Bad Objects: #{objects.find(:error => {:$exists => true}).count}, \
      Skipped Pages: #{extractor.pages.find(:transformation_error => {:$exists => true}).count}"
  end
  
  def print_update_info_for version
    p "Processed: #{objects.find(:version => version, :error => {:$exists => false}).count}, Bad Objects #{objects.find(:error => {:$exists => true}).count}"
  end
  
  def print_errors
    p "Objects: #{objects.count}, Processed Objects: #{objects.count}, Bad Objects #{objects.find(:error => {:$exists => true}).count}"
    puts objects.find(:error => {:$exists => true}).to_a.collect{|h| "#{h['error']} #{h['link']}"}.sort
  end  
  
  def clear
    base.db.drop_collection 'objects'
    
    extractor.pages.find({:transformed => true}, {}).each do |page|      
      page.delete 'transformed'
      page.delete 'transformation_error'
      extractor.pages.save page
    end
  end
  
  def run
    if options.clear?
      clear
      prepare
    end
    
    transformation.call self
  end
  
  protected
    def prepare
      self.objects = base.db.collection 'objects'
      objects.create_index 'identity', true
      objects.create_index 'error', false    
      objects.create_index 'version', false    
      
      self.extractor.pages.create_index 'transformed', false
    end
end