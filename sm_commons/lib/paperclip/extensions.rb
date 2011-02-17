# interpolation = "/system/:class/:attachment/:id_partition/:style_:filename"
interpolation = "/system/:account/:space/:class/:slug/:attachment/:filename_with_style"

Paperclip::Attachment.class_eval do
  default_options.merge!({
    :url => "#{ActionController::Base.relative_url_root}#{interpolation}",
    :path => ":rails_root/public" + interpolation,
    # :default_url   => "/:attachment/:style/missing.png",
  })
end

module Paperclip
  class << self
    def logger
      Rails.logger
    end
  end
  
  module Interpolations
    def filename_with_style attachment, style
      val = filename(attachment, style).clone
      if style.to_s != 'original'
        basename_index = val.rindex('.') || (val.size - 1)
        val.insert basename_index, ".#{style}"
      end
      val
    end
    
    # Handle string ids (mongo)
    # def id_partition attachment, style
    #   if (id = attachment.instance.id).is_a?(Integer)
    #     ("%09d" % id).scan(/\d{3}/).join("/")
    #   else
    #     id.to_s.scan(/.{3}/).first(3).join("/")
    #   end
    # end
    
    %w{name slug}.each do |name|
      define_method name do |attachment, style|
        attachment.instance.send name
      end
    end
    
    def account attachment, style
      Account.current.name
    end
    
    def space attachment, style
      Space.current.name
    end
  end
end