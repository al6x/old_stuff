class Multitenant::PagesController < Multitenant::MultitenantController  
  # require_permission :global_administration
  
  layout 'multitenant'
  
  active_menu{:home}

  def index
  end  















  
  # def ajax_method
  #   # respond_to do |format|
  #   #      js.do
  #   #        render :update do |page|
  #   #          page << "alert('hi')"
  #   #        end
  #   #      end
  #   #    end
  # end
  # 
  # def redirect
  #   redirect_to :action => :default
  # end
  # 
  # def default
  #   @title = 'default'
  #   # respond_to do |format|
  #   #   format.html{render :text => "html"}
  #   #   format.json{render :json => {:info => "json"}}
  #   # end
  # end
  # 
  # def json
  #   render :json => {:value => 'value'}
  # end
  # 
  # def test
  #   # html = RestClient.post "http://localhost:3000/service_mix_callbacks/test", {}
  #   # render :inline => html
  #   # render :inline => 'hi'    
  # end
  # 
  # def print
  #   render :inline => 'html'
  # end
end