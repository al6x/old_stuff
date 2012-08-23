class Rad::Assets::Resources::Css < Rad::Assets::Resource
  def pack!
    # Reading and merging sources.
    data = ""
    builded_fs_paths.each do |path|
      data << path.to_file.read
      data << "\n"
    end

    # Cleaning.
    data.gsub!(/\s+/, " ")           # collapse space
    data.gsub!(/\/\*(.*?)\*\//, "")  # remove comments - caution, might want to remove this if using css hacks
    data.gsub!(/\} /, "}\n")         # add line breaks
    data.gsub!(/\n$/, "")            # remove last break
    data.gsub!(/ \{ /, " {")         # trim inside brackets
    data.gsub!(/; \}/, "}")          # trim inside brackets

    # Writing.
    package_fs_path.to_file.write data
  end
end