class Rack::Request
  # it returns "application/x-www-form-urlencoded; charset=UTF-8" instead of "application/x-www-form-urlencoded"
  alias_method :content_type_without_fix, :content_type
  def content_type
    content_type_without_fix && content_type_without_fix.split(';').first
  end

  # alias_method :params_with_wrong_encoding, :params
  # def params
  #   @params ||= encode_in_utf8(params_with_wrong_encoding)
  # end
  #
  # protected
  #   def encode_in_utf8 hash
  #     r = {}
  #     hash.each do |k, v|
  #       r[k] = if v.is_a? String
  #         v.force_encoding("UTF-8")
  #       elsif v.is_a? Hash
  #         encode_in_utf8(v)
  #       else
  #         v
  #       end
  #     end
  #   end
end