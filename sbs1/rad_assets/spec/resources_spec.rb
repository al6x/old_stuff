require 'spec_helper'

describe 'Resources' do
  with_tmp_spec_dir
  inject assets: :assets

  describe "development" do
    before do
      assets.stub!(:fs_path){|http_path| "#{spec_dir}/development#{http_path}"}
      assets.stub!(:pack?).and_return(false)
    end

    it "resolve_http_paths" do
      assets.resolve_http_paths('/app.js').should == %w(/static/vendor/jquery.js /static/lib/tools.js /static/app.js)
    end
  end

  describe "production" do
    before do
      rad.http.stub!(:public_path).and_return("#{spec_dir}/production/public")
      assets.stub!(:pack?).and_return(true)
      @static_dir = "#{spec_dir}/production/public/static"
    end

    it "resolve_http_paths" do
      assets.resolve_http_paths('/app.js').should == %w(/static/app.packaged.js)

      packaged_file = "#{@static_dir}/app.packaged.js".to_file
      packaged_file.should exist
      packaged_file.read.should =~ /jQuery.*Tools.*App/m

      "#{@static_dir}/lib/tools.packaged.js".to_file.should exist
      "#{@static_dir}/vendor/jquery.packaged.js".to_file.should exist
    end

    it "should create new packed version if sources are updated" do
      assets.resolve_http_paths('/app.js').should == %w(/static/app.packaged.js)
      packaged_file = "#{@static_dir}/app.packaged.js".to_file
      packaged_file.read.should =~ /jQuery.*Tools.*App/m

      sleep 1.1 # file system can't notice smaller difference in file update time
      "#{@static_dir}/vendor/jquery.js".to_file.write "newQuery"
      assets.resolve_http_paths('/app.js').should == %w(/static/app.packaged.js)
      packaged_file.read.should =~ /newQuery.*Tools.*App/m
    end
  end
end