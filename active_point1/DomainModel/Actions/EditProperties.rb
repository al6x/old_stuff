class EditProperties < Action	
  attr_accessor :form
  
  def execute							
    cform = ContainerForm.new :metadata => self		
    begin
      aform = form.new :metadata => self 
    rescue Exception => e
      log.error "Can't initialize the #{form} Form (#{e.message})!"
      raise e
    end		
    
    cform.add aform
    cform[:form].add aform
    
    controller.view = cform		
    view.values = object		
  end
  
  def on_ok
    new_values = view.values
    operation_processor.execute klass, name, :entity => object, :properties => new_values	
    finish	
  end
  
  def choose_next
    controller.execute :on_view
  end
end