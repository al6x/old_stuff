module FileModel::MiniMagic
  def mini_magic callback, &block
    return unless original

    require 'mini_magick'
    image = MiniMagick::Image.open(original.path)
    block.call image
    '/'.to_entry.tmp do |dir|
      output = dir / :tmp_image
      image.write output.path
      callback.call output
    end
  end
end