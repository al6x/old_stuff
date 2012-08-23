class Rad::Cli
  RUNTIME_DIR = 'runtime'

  inject :logger

  def run_console
    set_runtime_path!

    load './init.rb' if './init.rb'.to_file.exist?
    rad.environment

    require 'irb'
    IRB.start
  end

  def run_server
    set_runtime_path!

    require 'rack'
    require 'rack/builder'
    app, options = Rack::Builder.parse_file 'config.ru'

    rad.http.run app
  end

  def set_runtime_path!
    Dir.chdir RUNTIME_DIR if Dir.exist? RUNTIME_DIR
  end
end