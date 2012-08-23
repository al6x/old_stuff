require 'addressable/uri'
::Uri = Addressable::URI

Addressable::URI.class_eval do
  def request_uri
    return nil if self.absolute? && self.scheme !~ /^https?$/
    return (
      (self.path != "" ? self.path : "/") +
      (self.query ? "?#{self.query}" : "")
    )
  end

  def self.normalize_host host
    host.gsub(/^www\./, "")
  end

  def normalized_host
    host ? host : host.gsub(/^www\./, '')
  end

  # Delete 'nil' keys
  alias_method :query_values_without_nill_skipping, :query_values
  def query_values= options
    to_delete = []
    options.each{|k, v| to_delete << k if v.nil?}
    to_delete.each{|k| options.delete k}

    self.query_values_without_nill_skipping = options
  end

  # Override original to fix:
  # - extra '?' sign (/some_path?) if there's empty but not-nil query
  def to_s
    @uri_string ||= (begin
      uri_string = ""
      uri_string << "#{self.scheme}:" if self.scheme != nil
      uri_string << "//#{self.authority}" if self.authority != nil
      uri_string << self.path.to_s
      uri_string << "?#{self.query}" unless self.query.blank?
      uri_string << "##{self.fragment}" if self.fragment != nil
      if uri_string.respond_to?(:force_encoding)
        uri_string.force_encoding(Encoding::UTF_8)
      end
      uri_string
    end)
  end
end