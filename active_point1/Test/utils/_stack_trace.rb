require 'utils/class_auto_loader'

module ::Utils
    module StackTrace
        def self.remove_file stack, file
            pattern = /#{file.split(/[\/\\]/).last}/
            return stack.delete_if{|line| line =~ pattern}
        end                
        
        def self.remove_self stack, klass            
            pattern = /#{::Utils::ClassAutoLoader::QualifiedName.class_to_path klass.name}/
            return stack.delete_if{|line| line =~ pattern}
        end        
    end
end