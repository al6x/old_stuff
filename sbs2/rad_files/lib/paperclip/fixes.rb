#
# Paperclip overrides :make_tmpname method of Tempfile. But in ruby 1.9.2 instead of number in n comes nil, 
# so we fixin it.
#
module Paperclip
  class Tempfile < ::Tempfile
    def make_tmpname(basename, n)
      n ||= 0 # <= fix
    
      extension = File.extname(basename)
      sprintf("%s,%d,%d%s", File.basename(basename, extension), $$, n, extension)
    end
  end
end


#
# Ruby 1.9.2 doesn't raise error if FileUtils.rmdir failed
#
module Paperclip
  module Storage
    module Filesystem
      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|
          begin
            log("deleting #{path}")
            FileUtils.rm(path) if File.exist?(path)
          rescue Errno::ENOENT => e
            # ignore file-not-found, let everything else pass
          end
          begin
            while(true)
              path = File.dirname(path)
              FileUtils.rmdir(path)
              break if File.exists?(path) # Ruby 1.9.2 does not raise if the removal failed.
            end
          rescue Errno::EEXIST, Errno::ENOTEMPTY, Errno::ENOENT, Errno::EINVAL, Errno::ENOTDIR
            # Stop trying to remove parent directories
          rescue SystemCallError => e
            log("There was an unexpected error while deleting directories: #{e.class}")
            # Ignore it
          end
        end
        @queued_for_delete = []
      end
    end
  end
end