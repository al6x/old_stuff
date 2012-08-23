begin
  Globalize # should be defined
  
  # Russian pluralization
  I18n.backend.add_pluralizer :ru, lambda{|n| 
    # Правило плюрализации для русского языка, взято из CLDR, http://unicode.org/cldr/
    #
    #
    # Russian language pluralization rules, taken from CLDR project, http://unicode.org/cldr/
    #
    #   one -> n mod 10 is 1 and n mod 100 is not 11;
    #   few -> n mod 10 in 2..4 and n mod 100 not in 12..14;
    #   many -> n mod 10 is 0 or n mod 10 in 5..9 or n mod 100 in 11..14;
    #   other -> everything else
    #
    # Пример
    #
    #   :one  = 1, 21, 31, 41, 51, 61...
    #   :few  = 2-4, 22-24, 32-34...
    #   :many = 0, 5-20, 25-30, 35-40...
    #   :other = 1.31, 2.31, 5.31...
    n % 10 == 1 && n % 100 != 11 ? :one : [2, 3, 4].include?(n % 10) && ![12, 13, 14].include?(n % 100) ? :few : n % 10 == 0 || [5, 6, 7, 8, 9].include?(n % 10) || [11, 12, 13, 14].include?(n % 100) ? :many : :other 
  }

  # t() and t_scope()
  list = [Object, ActionController::Base, ActionView::Base, ActionMailer::Base]
  list << ActiveRecord::Base if defined?(ActiveRecord)
  list.each do |aclass|
    aclass.class_eval do
      
      # def self.t_scope_value; end # hack, becouse of rails method_missing magic it causes error
      # def t_scope_value; end # hack, becouse of rails method_missing magic it causes error
      # 
      # def self.t_scope *scopes
      #   class_inheritable_accessor :t_scope_value unless respond_to? :t_scope_value
      #   self.t_scope_value = scopes.collect{|scope| scope + "_scope"}
      # end
  
      # finding translation in all class hierarchy
      # def t message, params = {}
      #   # begin
      #   #   p([message, respond_to(:t_scope_value)])
      #   # rescue
      #   #   p([self.t_scope_value])
      #   # end
      #   
      #   result = nil
      #   
      #   aclass = self.is_a?(Class) ? self : self.class
      #   list = aclass.ancestors
      #   list.unshift self unless self.is_a?(Class) # hack for ActionView and ActionMailer
      #   
      #   catch :found do 
      #     list.each do |c|
      #       t_scope = begin
      #         c.respond_to(:t_scope_value)
      #       rescue NameError # hack for rails method_missing magic
      #         begin 
      #           c.t_scope_value
      #         rescue NoMethodError
      #           nil
      #         end
      #       end
      #             
      #       next unless t_scope
      #     
      #       t_scope.each do |ts|
      #         begin
      #           result = I18n.t "#{ts}.#{message}", params.merge(:raise => true)
      #         rescue I18n::MissingTranslationData
      #         end
      #         throw :found if result
      #       end
      #     end
      #   end
      #   
      #   result ||= I18n.t message, params
      #   result.to_s # Globalize2 uses Translation::Static instead of String
      # end
      
      def t *args
        # Globalize2 uses Translation::Static instead of String
        I18n.t(*args).to_s
      end
    
    end
  end
    
  # ActionController::Base.class_eval do
  #   # Becouse we need to transfer @t_scope also to View
  #   def initialize_with_t_scope *args, &block
  #     initialize_without_t_scope *args, &block
  #     t_scope = self.class.t_scope_value
  #     @t_scope_value = t_scope if t_scope
  #   end
  #   alias_method_chain :initialize, :t_scope
  # end
  
  ActionView::Base.class_eval do
    # def t_scope_value
    #   controller.class.t_scope_value if controller.class.respond_to? :t_scope_value
    # end
  end
  
  ActionMailer::Base.class_eval do
    # def t_scope_value
    #   controller.class.t_scope_value if controller.class.respond_to? :t_scope_value
    # end
    # def t_scope scope
    #   raise 'stub! use the same'
    #   @t_scope = scope
    #   @body[:t_scope] = @t_scope
    # end
  end
  
  # Prepare locale in Controller
  # module ActionController
  #   module Acts
  #     module Localized
  #       def self.included(base)
  #         base.extend(ClassMethods)
  #       end
  # 
  #       module ClassMethods
  #         def acts_as_localized
  #           include ActionController::Acts::Localized::InstanceMethods
  #           
  #           before_filter :prepare_locale
  #         end        
  #       end
  #       
  #       module InstanceMethods
  #         def prepare_locale
  #           I18n.locale = params[:l] unless params[:l].blank?
  #         end
  #       end
  #     end
  #   end
  # end
  # ActionController::Base.send :include, ActionController::Acts::Localized
# rescue NameError 
#   puts "i18n_helper (from rails_commons) disabled"
end