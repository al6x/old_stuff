Object.class_eval do
  def send_with_params method_name, params, &block
    params ||= {}
    method = self.method method_name
    args = []
    method.parameters.each do |type, name|
      included, value = params.include?(name), params[name]
      if name == :params
        args << params
      elsif type == :opt or type == :rest
        args << value if included
      elsif type == :req
        included ? args << value : raise("missing :#{name} parameter!")
      else
        raise "unknow argument type #{type}!"
      end
    end
    send method_name, *args, &block
  end
end