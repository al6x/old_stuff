module Rad::AbstractRoutingHelper
  protected
    def special_url key
      return nil unless (key.is_a?(Symbol) or key.is_a?(String))

      if key == :back
        workspace.request.env["HTTP_REFERER"] || 'javascript:history.back()'
      elsif key == '#'
        '#'
      # elsif key =~ /^http:\/\// # /^[\/0-9_a-z]+$/i
      #   key
      else
        nil
      end
    end

    def keep_flash!
      rad[:flash].keep! if rad.include? :flash
    end
end