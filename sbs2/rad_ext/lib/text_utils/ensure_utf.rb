class TextUtils::EnsureUtf < TextUtils::Processor
  def call data, env
    data = call_next data, env

    # Escape all non-word unicode symbols, otherwise it will raise error when converting to BSON.
    require 'iconv'
    data = Iconv.conv('UTF-8//IGNORE//TRANSLIT', 'UTF-8', data)

    unless data.encoding == Encoding::UTF_8
      raise "something wrong happens, invalid encoding (#{data.encoding} instead of utf-8)!"
    end

    data
  end
end