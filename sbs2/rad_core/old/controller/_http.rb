module Rad::Controller::Http
  inherit Rad::Controller::Abstract

  def render *args
    if args.size == 1 and (status = Rad::Http::Response.decode_status_message(args.first))
      response.set! status: status
      throw :halt, ""
    else
      super
    end
  end

  protected
    def render_content options
      if response
        response.set!(
          status: options[:status] || :ok,
          content_type: options[:content_type] || Rad::Mime[params.format]
        )
      end

      if options[:location]
        redirect_to options[:location]
      else
        super
      end
    end

  module ClassMethods
    inheritable_accessor :actions_allowed_for_get_request, []

    def allow_get_for *methods
      methods = methods.first if methods.first.is_a? Array

      enable_protection_from_get_requests!
      actions_allowed_for_get_request.push *(methods.collect(&:to_sym))
    end

    private
      def enable_protection_from_get_requests!
        unless respond_to? :protect_from_get_request
          define_method :protect_from_get_request do
            get = !(request.post? or request.put? or request.delete?)
            if get and !self.class.actions_allowed_for_get_request.include?(action_name)
              raise "GET request not allowed for :#{action_name} action!"
            end
          end
          before :protect_from_get_request
        end
      end
  end
end