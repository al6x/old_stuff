# interpolation = "/fs/:class/:attachment/:id_partition/:style_:filename"
interpolation = "/fs/:account/:space/:class/:slug/:attachment/:filename_with_style"

# Paperclip::Attachment.class_eval do
#   default_options.merge!({
#     url: "#{ActionController::Base.relative_url_root}#{interpolation}",
#     path: ":rails_root/public" + interpolation,
#     # default_url: "/:attachment/:style/missing.png",
#   })
# end
rad.after :environment do
  Paperclip::Attachment.class_eval do
    default_options.merge!({
      # url => "#{ActionController::Base.relative_url_root}#{interpolation}",
      url: (rad.config.url_root! + interpolation),
      path: ":public_path" + interpolation,
      # default_url: "/:attachment/:style/missing.png",
    })
  end
end

module Paperclip
  class << self
    inject logger: :logger
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
    
    def runtime_path attachment, style
      rad.config.runtime_path!
    end
    alias_method :app_root, :runtime_path
    
    def public_path attachment, style
      rad.config.public_path!
    end
  end
end