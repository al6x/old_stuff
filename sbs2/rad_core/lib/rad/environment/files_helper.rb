module Rad::Environment::FilesHelper
  def directories
    $LOAD_PATH
  end

  def file_exist? path, directories = nil
    find_files(path, directories).size > 0
  end

  def find_files fname, directories = nil
    directories ||= self.directories
    Rad::Environment::FilesHelper.find_files fname, directories
  end

  def find_files_without_cache fname, directories = nil
    Rad::Environment::FilesHelper.find_files_without_cache fname, directories
  end

  def find_file fname, directories = nil
    files = find_files(fname, directories)
    raise "Found multiple files for '#{fname}'" if files.size > 1
    files.first
  end

  def find_file! fname, directories = nil
    find_file(fname, directories) || raise("File '#{fname}' not found!")
  end

  def find_files_by_pattern_without_cache pattern, directories = nil
    directories ||= self.directories
    patterns = directories.to_a.collect{|d| "#{d}#{pattern}"}
    Dir.glob patterns
  end
  alias_method :find_files_by_pattern, :find_files_by_pattern_without_cache

  def find_file_by_pattern pattern
    files = find_files_by_pattern(pattern)
    raise "File '#{pattern}' not found!" if files.size == 0
    raise "Found multiple files for '#{pattern}'" if files.size > 1
    files.first
  end

  class << self
    # Don't move this class method to module, because there will be then
    # multiple cache for every object that includes it.
    def find_files fname, directories
      fname.must =~ /\//
      directories.must.be_present
      files = directories.collect{|dir| "#{dir}#{fname}"}
      files.select{|f| File.exist? f}
    end
    cache_method_with_params_in_production :find_files
  end
end