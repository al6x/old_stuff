module RailsExt
  class << self
    def create_public_symlinks! root = RAILS_ROOT
      public_rails_ext_path = File.expand_path "#{File.dirname __FILE__}/../../../public/rails_ext"
      raise "File #{public_rails_ext_path} don't exist!" unless File.exist? public_rails_ext_path
      public_rails_path = File.expand_path "#{root}/public/rails_ext"
      
      system "ln -nfs #{public_rails_ext_path} #{public_rails_path}"
    end
  end
end