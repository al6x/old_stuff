require 'spec_helper'

describe 'Resources' do
  with_tmp_spec_dir
  inject :assets

  describe "development" do
    before do
      assets.stub!(:fs_path){|http_path| "#{spec_dir}/development#{http_path}"}
      assets.stub!(:pack?).and_return false
    end

    it "get" do
      assets.get('/my_app.js').should ==
        %w(/assets/vendor/my_jquery.js /assets/lib/my_tools.js /assets/my_app.js)
    end
  end

  describe "production" do
    before do
      rad.http.stub!(:public_path).and_return "#{spec_dir}/production/public"
      assets.stub!(:pack?).and_return true
      @assets_dir = "#{spec_dir}/production/public/assets"
    end

    it "get" do
      assets.get('/my_app.js').should == %w(/assets/packaged/my_app.js)

      packaged_file = "#{@assets_dir}/packaged/my_app.js".to_file
      packaged_file.should exist
      content = packaged_file.read
      content.should =~ /jQuery.*Tools.*App/m

      # Shouldn't require twice (from error).
      content.should_not =~ /jQuery.*jQuery/m

      # Should not build other files.
      "#{@assets_dir}/packaged/lib/my_tools.js".to_file.should_not exist
      "#{@assets_dir}/packaged/vendor/my_jquery.js".to_file.should_not exist
    end

    it "should create new packed version if sources are updated" do
      assets.get('/my_app.js').should == %w(/assets/packaged/my_app.js)
      packaged_file = "#{@assets_dir}/packaged/my_app.js".to_file
      packaged_file.read.should =~ /jQuery.*Tools.*App/m

      # sleep 1.1
      # File system can't notice differences smaller than 1 sec in file update,
      # but I don't want to wait for it and use this complex stub.
      Rad::Assets::Resources::Js.send :public, :source_updated_at
      Rad::Assets::Resources::Js.after_instantiate do |instance|
        instance.stub! :source_updated_at do
          value = instance.source_fs_path.to_file.updated_at
          if instance.source_path == '/vendor/my_jquery.js'
            value + 10
          else
            value
          end
        end
      end

      "#{@assets_dir}/vendor/my_jquery.js".to_file.write "newQuery"
      assets.get('/my_app.js').should == %w(/assets/packaged/my_app.js)
      packaged_file.read.should =~ /newQuery.*Tools.*App/m
    end
  end
end