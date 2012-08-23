class TextUtils::FormatQualifier < TextUtils::Processor
  def call data, env
    env[:format] = (
      (data =~ /\A\s*<[a-z_\-0-9]+>.*<\/[a-z_\-0-9]+>\s*\z/im) or
      (data =~ /\A\s*<[a-z_\-0-9]+\/>\s*\z/i)
    ) ? :html : :markdown

    data = call_next data, env

    raise "some processor in pipe clear the data format!" unless env[:format]
    data
  end
end