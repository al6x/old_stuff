require 'mongoid_misc/spec'

module CarrierWaveExtSpecHelper
  TEST_PATH, TEST_CACHE_PATH = '/tmp/spec_fs', '/tmp/spec_fs_cache'
  
  def with_files
    before do
      CarrierWave.configure do |config|          
        config.storage = :file
        config.enable_processing = false
        
        config.cache_dir = TEST_CACHE_PATH
        config.root = TEST_PATH
      end
    end
    
    before do 
      [TEST_PATH, TEST_CACHE_PATH].each{|p| FileUtils.rm_r(p) if File.exist?(p)}
    end
    before do 
      [TEST_PATH, TEST_CACHE_PATH].each{|p| FileUtils.rm_r(p) if File.exist?(p)}
    end
  end    
end
rspec.extend CarrierWaveExtSpecHelper