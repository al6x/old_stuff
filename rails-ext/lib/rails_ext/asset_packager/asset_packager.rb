module AssetPackager
  class << self
    def add yaml_file_path, asset_path
      definition = YAML.load File.read(yaml_file_path)
      definition.should! :be_a, Hash
      self.definitions[asset_path] = definition
    end
    
    def build_all
      definitions.each do |path, package_types|
        package_types.each do |type, package|
          package.each do |name, files|
            build = self.send "build_#{type}", path, name, files
            dir = "#{public_root}/#{type}"
            FileUtils.mkdir_p dir unless File.exist? dir
            fname = public_root + filename_for_builded_package(type, name)
            File.open(fname, "w"){|f| f.write(build)}
          end
        end
      end
    end

    def delete_all
      definitions.each do |path, package_types|
        package_types.each do |type, package|
          package.each do |name, files|
            fname = public_root + filename_for_builded_package(type, name)
            File.delete fname if File.exist? fname
          end
        end
      end
    end
    
    def filename_for_builded_package type, package
      type = type.to_s
      "/#{type}/#{package}_packaged.#{AssetPackager.resources_extensions[type]}"
    end
    
    def definitions
      @definitions ||= {}
    end
        
    def merge_environments
      @merge_environments ||= ["production"]
    end
    
    protected
      def public_root
        "#{Rails.root}/public"
      end
      
      def tmp_path
        "#{Rails.root}/tmp"
      end
    
      def resources_extensions
        @resources_extensions ||= {
          'javascripts' => 'js',
          'stylesheets' => 'css'
        }
      end
      
      def build_javascripts path_to_files, package, files
        merged = merge_file path_to_files, files
        
        # write out to a temp file
        tmp_file = "#{tmp_path}/#{package}_packaged"
        File.open("#{tmp_file}_uncompressed.js", "w"){|f| f.write(merged)}
      
        # compress file with JSMin library
        jsmin = "#{File.dirname(__FILE__)}/jsmin.rb"
        `ruby #{jsmin} <#{tmp_file}_uncompressed.js >#{tmp_file}_compressed.js \n`

        # read it back in and trim it
        result = ""
        File.open("#{tmp_file}_compressed.js", "r") { |f| result += f.read.strip }
  
        # delete temp files if they exist
        File.delete("#{tmp_file}_uncompressed.js") if File.exists?("#{tmp_file}_uncompressed.js")
        File.delete("#{tmp_file}_compressed.js") if File.exists?("#{tmp_file}_compressed.js")

        result
      end
      
      def build_stylesheets path_to_files, package, files
        merged = merge_file path_to_files, files
        
        merged.gsub!(/\s+/, " ")           # collapse space
        merged.gsub!(/\/\*(.*?)\*\//, "")  # remove comments - caution, might want to remove this if using css hacks
        merged.gsub!(/\} /, "}\n")         # add line breaks
        merged.gsub!(/\n$/, "")            # remove last break
        merged.gsub!(/ \{ /, " {")         # trim inside brackets
        merged.gsub!(/; \}/, "}")          # trim inside brackets
        merged
      end
      
      def merge_file path_to_files, files
        merged_file = ""
        files.each do |fname| 
          full_path = if fname =~ /\A\//
            "#{public_root}#{fname}"
          else
            "#{path_to_files}/#{fname}"
          end
          File.open(full_path, "r") do |f| 
            merged_file += f.read + "\n" 
          end
        end
        merged_file
      end
  end
end