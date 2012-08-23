class Rad::Http::Request
  include RubyExt::OpenConstructor

  DATA_PARSERS = {
    'json' => -> data {JSON.parse data},
    'html' => -> data {{}}
  }

  attr_reader :rack_request

  def initialize rack_request = nil
    @rack_request = rack_request || Rad::Http::RackRequest.new({})
  end

  attr_writer :path
  def path
    @path ||= rack_request.path
  end

  def method
    rack_request.request_method
  end

  attr_writer :format
  def format
    @format ||= Rad::Mime.format_for(rack_request.content_type) || rad.http.default_format
  end

  def uri
    @uri ||= Uri.parse rack_request.url
  end

  # def args
  #   @args ||= begin
  #     parser = DATA_PARSERS[format] || raise("no parser for #{format}!")
  #     args = if data = params[:data]
  #       data = data[0..rad.http.maximum_data_size].url_unescape
  #       parser.call data, self
  #     elsif data = rack_request.body.read(rad.http.maximum_data_size)
  #       parser.call data, self
  #     else
  #       if params.empty? or (params.size == 1 and params.include? :id)
  #         []
  #       else
  #         [params]
  #       end
  #     end
  #     args.unshift params[:id] if params.include? :id
  #     args
  #   end
  # end

  # Symbolizing parameters and merging with extra parameters encoded as JSON.
  attr_writer :params
  def params
    unless @params
      @params = {}
      rack_request.params.each{|k, v| @params[k] = v}

      # Adding post data.
      if data = rack_request.body.read(rad.http.maximum_data_size)
        parser = DATA_PARSERS[format] || raise("no parser for #{format}!")
        data = parser.call data
        data.class.must == Hash
        @params.merge! data
      end

      @params = Hash.symbolize @params

      # if json_data = @params.delete(:json)
      #   params = JSON.load json_data
      #   params.must.be_a Hash
      #   params.each do |k, v|
      #     k = k.to_sym
      #     logger.warn "HTTP parameter :#{k} will be overwriden from JSON!" if @params.include? k
      #     @params[k] = v
      #   end
      # end
    end
    @params
  end
end