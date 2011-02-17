# Doesn't works if it's included in Rails, should be explicitly copied to tasks folder.

namespace :asset do
  namespace :packager do

    desc "Merge and compress assets"
    task :build_all => :environment do
      require 'yaml'
      require 'asset_packager/asset_packager'
      
      AssetPackager.build_all
      
      puts "Asset builded"
    end

    desc "Delete all asset builds"
    task :delete_all do
      require 'yaml'
      require 'asset_packager/asset_packager'
      
      AssetPackager.delete_all
      
      puts "Asset Builds deleted"
    end
    
  end
end