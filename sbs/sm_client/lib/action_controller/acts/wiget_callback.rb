module ActionController
  module Acts
    module WigetCallback
      module ClassMethods
        def acts_as_wiget_callback
          filter_parameter_logging :json_params
          
          include ActionController::Acts::WigetCallback::InstanceMethods
          
          around_filter :catch_user_error_as_json
          acts_as_localized
          before_filter :check_access
          acts_as_multitenant
          acts_as_authorized          
          
          # before_filter :prepare_resource
          before_filter :prepare_json_parameters
        end        
      end
      
      module InstanceMethods

        
        # def update_rating
        #   begin 
        #     rating = params[:rating].should_not_be!(:blank)
        #     if @resource.respond_to? :rating
        #       @resource.rating = rating 
        #       @resource.save!
        #     end
        #     render :json => {}
        #   rescue RuntimeError => e
        #     raise_user_error "Internal Error in update_rating"
        #   end
        # end
        # 
        # def update_comments
        #   begin 
        #     comments_count = params[:comments_count].should_not_be!(:blank)
        #     if @resource.respond_to? :comments_count
        #       @resource.comments_count = comments_count
        #       @resource.save!
        #     end
        #     render :json => {}
        #   rescue RuntimeError => e
        #     raise_user_error "Internal Error in update_comments"
        #   end
        # end
        
        protected
          def check_access
            raise_user_error "Only Post Requests allowed!" unless request.post?
            raise_user_error "Access denied!" unless params[:api_key] == SETTING.api_key!
          end

          def catch_user_error_as_json
            begin
              yield
            rescue UserError => e
              render :json => {:error => e.message}
            end
          end
          
          # def prepare_resource
          #   return unless params[:resource_type]
          #   
          #   resource_class = params[:resource_type].should_not_be!(:blank).constantize
          #   begin
          #     @resource = resource_class.find! params[:resource_id].should_not_be!(:blank)
          #   rescue MongoMapper::DocumentNotFound => e
          #     raise_user_error e.message
          #   end
          # end
          
          attr_reader :json_params
          def prepare_json_parameters
            @json_params = JSON.parse params[:json_params] if params[:json_params]
            @json_params ||= HashWithIndiferentAccess.new
            Rails.development do
              dump = json_params.inspect
              # dump = "[very large data ... ]" if dump.size > 1000
              logger.debug "  JSON Parameters: #{dump}" 
            end
          end
      end
      
    end
  end
end
ActionController::Base.inherit ActionController::Acts::WigetCallback