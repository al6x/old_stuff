class Rad::Assets::Compressor
  COMPRESSORS = {
    # js: -> path, packaged_path {
    #   jsmin = "#{__FILE__.dirname}/../vendor/jsmin.rb"
    #   `ruby #{jsmin} <#{path} >#{packaged_path} \n`
    # },
    css: -> path, packaged_path {
      data = path.to_file.read
      data.gsub!(/\s+/, " ")           # collapse space
      data.gsub!(/\/\*(.*?)\*\//, "")  # remove comments - caution, might want to remove this if using css hacks
      data.gsub!(/\} /, "}\n")         # add line breaks
      data.gsub!(/\n$/, "")            # remove last break
      data.gsub!(/ \{ /, " {")         # trim inside brackets
      data.gsub!(/; \}/, "}")          # trim inside brackets
      packaged_path.to_file.write data
    }
  }

  def self.pack! path
    file = path.to_file.must.exist
    packager = COMPRESSORS[file.extension.to_sym]
    if packager
      tmp = "#{path}.tmp"
      tmp.to_file.destroy
      packager.call file.path, tmp
      file.destroy
      FileUtils.mv tmp, file.path
    end
  end
end