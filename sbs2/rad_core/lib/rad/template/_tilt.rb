module Tilt
  # Include it into your template context class for :output, :capture and :concat support.
  module ContextExt
    def output
      _tilt_template.class.output(self)
    end

    def capture *args, &block
      _tilt_template.class.capture self, &block
    end

    def concat value
      _tilt_template.class.concat self, value
    end
  end

  class Template
    def self.get_output context
      raise "Output variable for #{self.class} not defined!"
    end

    def self.capture context, &block
      raise "capture not implemented for #{self.class}!"
    end

    def self.concat context, value
      raise "concat not implemented for #{self.class}!"
    end
  end

  class ERBTemplate
    def self.get_output context
      context.instance_variable_get "@output"
    end

    def self.capture context, &block
      begin
        old_output = context.instance_variable_get "@output"
        old_output.must.be_defined
        context.instance_variable_set "@output", ""
        block.call
        context.instance_variable_get "@output"
      ensure
        context.instance_variable_set "@output", old_output
      end
    end

    def self.concat context, value
      get_output(context) << value
    end
  end

  class HamlTemplate
    def self.get_output context
      context.haml_buffer.buffer
    end

    def self.capture context, &block
      context.capture_haml &block
    end

    def self.concat context, value
      context.haml_concat value
    end
  end
end