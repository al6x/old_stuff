module Rad::Mime
  class << self
    def [] type
      require 'rack'

      type = ".#{type}" unless type =~ /^\./
      Rack::Mime.mime_type(type) || raise("Unknown MIME type: #{type}")
    end

    def format_for content_type
      require 'rack'

      Rack::Mime::MIME_TYPES.each do |format, type|
        return format[1..-1] if type == content_type
      end
      nil
    end

    def image? file_name
      require 'rack'

      return false if file_name.blank?
      extension = File.extname(file_name)
      Rack::Mime.mime_type(extension) =~ /image/
    end

    protected
      def method_missing m, *args, &block
        args.empty? ? self[m] : super
      end
  end
end