module Models::Multitenant
  module ClassMethods
    def belongs_to_space
      raise "model #{self} already belongs to Space!" if method_defined? :account_id

      attr_accessor :space_id
      define_method :space do
        _cache[:space] ||= begin
          if space_id
            Models::Space.by_id space_id
          elsif Models::Space.current?
            self.space = Models::Space.current
            Models::Space.current
          else
            nil
          end
        end
      end
      define_method :space= do |space|
        self.space_id = space._id
        _cache[:space] = space
      end
      before_validate :space
      validates_presence_of :space_id


      default_scope do
        Models::Space.current? ? {space_id: Models::Space.current._id} : {}
      end


      model, association_name = self, self.alias.underscore.pluralize.to_sym
      Models::Space.class_eval do
        define_method association_name do
          model.query space_id: _id
        end
        after_destroy{|m| m.send(association_name).each &:destroy!}
      end
    end
  end
end