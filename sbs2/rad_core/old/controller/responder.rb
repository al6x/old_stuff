class Rad::Controller::Abstract::Responder < BasicObject
  attr_reader :handlers

  def initialize
    @handlers = {}
  end

  protected
    def method_missing m, *args, &block
      args.must.be_empty
      handlers[m.to_s] = block || lambda{} #.must.be_defined
    end
end