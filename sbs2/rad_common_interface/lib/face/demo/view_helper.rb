module Rad::Face::Demo::ViewHelper
  def samples
    @samples
  end

  def t key, options = {}
    key.to_s
  end

  def demo_metadata
    unless @demo_metadata
      logger.info "RAD complex calculation :demo_metadata called!"
      @demo_metadata = {}
      name = "#{template.directory_name}#{rad.face.themes_path}/#{theme.name}/demo_metadata.rb"
      if rad.environment.file_exist? name, rad.template.paths
        fname = rad.environment.find_file! name, rad.template.paths
        code = File.read fname
        @demo_metadata = eval code
        @demo_metadata.must.be_a Hash        
      end
      @demo_metadata = @demo_metadata.to_openobject
    end
    @demo_metadata
  end
  
  def random_attachment
    samples.attachments[rand(samples.attachments.size)]
  end
end