module Rad::CliHelper
  RUNTIME_DIR = 'runtime'

  class << self
    inject logger: :logger
    
    def run_console
      prepare_running_environment

      require 'irb'
      IRB.start        
    end

    def run_server
      app = prepare_running_environment
  
      rad.http.run app, rad.http.host, rad.http.port
    end
      
    def use_runtime_path!
      runtime_path = "./#{RUNTIME_DIR}"
      Dir.chdir runtime_path if Dir.exist? runtime_path
    end

    protected
      def prepare_running_environment
        use_runtime_path!
        
        require 'rack'
        app, options = Rack::Builder.parse_file 'config.ru'
        app
      end
  end
end