class Rad::Assets::Resources::Js < Rad::Assets::Resource
  def pack!
    # Reading and merging sources.
    data = ""
    builded_fs_paths.each do |path|
      data << path.to_file.read
      data << "\n"
    end

    # Minifying.
    uncompressed = (package_fs_path + '.uncompressed').to_file
    uncompressed.write data

    jsmin = "#{__FILE__.dirname}/../vendor/jsmin.rb"
    `ruby #{jsmin} <#{uncompressed.path} >#{package_fs_path} \n`
  end
end