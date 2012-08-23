class Rad::Conveyors::Conveyor
  inject :workspace

  def definitions
    @definitions ||= []
  end

  def use processor_class, *initialization_arguments
    definitions << [processor_class, initialization_arguments]
  end

  def build!
    @chain = lambda{}
    definitions.reverse.collect do |klass, args|
      klass.must.be_a Class
      @chain = klass.new @chain, *args
    end
  end

  def call workspace_content = {}, &block
    build! unless @chain

    scope = (rad.custom_scopes[:cycle] || {}).clone
    rad.activate :cycle, scope do
      self.workspace = ::Rad::Conveyors::Workspace.new unless self.workspace?
      workspace.merge! workspace_content

      if block
        block.call(@chain)
      else
        @chain.call
      end

      workspace
    end
  end

  def inspect
    definitions.inspect
  end

  # def trace name, &block
  #   start_time = Time.now
  #   block.call
  #   (workspace.trace ||= []) << [name, Time.now - start_time]
  # end

  protected
    # def build_chain
    #   next_processor_call = nil
    #   chain = reverse.collect do |processor|
    #     next_processor_call = if next_processor_call
    #       lambda{processor.call next_processor}
    #     else
    #       lambda{processor.call lambda{}}
    #     end
    #   end
    #   next_processor_call
    # end


  # def add_before key, *processors
  #   index = index{|processor| processor.name == key or processor.class == key}
  #   raise "Can't find Processor '#{name}'!" unless index
  #   insert index, *Array(processors)
  # end
  #
  # def add_after key, *processors
  #   index = rindex{|processor| processor.name == key or processor.class == key}
  #   raise "Can't find Processor '#{name}'!" unless index
  #   insert index + 1, *Array(processors)
  # end
end