rad.html

# Converts {'model[attribute]' => value} into {'model' => {'attribute' => value}}
class ScopedParams < Rad::Conveyors::Processor
  def call
    if workspace.params?
      to_delete = []
      to_add = {}
      workspace.params.each do |name, value|
        name.to_s.scan /(.+)\[(.+)\]/ do |scope_name, name_in_scope|
          logger.warn "RAD owerriding :#{scope} param!" if workspace.params.include? scope_name
          scope = to_add[scope_name.to_sym] ||= {}
          scope[name_in_scope] = value
          to_delete << name
        end
      end
      workspace.params.merge! to_add
      to_delete.each{|n| workspace.params.delete n}
    end

    next_processor.call
  end
end