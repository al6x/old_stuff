require 'fileutils'

File.class_eval do
  def file_name
    File.basename path
  end

  class << self
    def write(path, data)
      File.open(path, "wb") do |file|
        return file.write(data)
      end
    end

    # def create_directory dir
    #   FileUtils.mkdir_p dir unless File.exist? dir
    # end
    #
    # def delete_directory dir
    #   FileUtils.rm_r dir, force: true if File.exist? dir
    # end
  end
end