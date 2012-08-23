class Rad::Logger
  def initialize stream = nil
    @stream = stream
  end

  def silence &b
    begin
      @silence = true
      b.call
    ensure
      @silence = false
    end
  end

  def info obj
    write obj_to_string(obj)
  end

  def warn obj
    write "WARN: " + obj_to_string(obj)
  end

  def error obj
    write "ERROR: " + obj_to_string(obj)
  end

  def debug obj
    write obj_to_string(obj).gsub(/BSON::ObjectId\(([a-z0-9'"]+)\)/, "\\1")
  end

  protected
    def write str
      if !@silence
        str = indent(str)
        stream ? stream.write(str) : puts(str)
      end
    end

    IDENTATION = "  "
    attr_reader :stream

    def indent string
      IDENTATION + string.gsub("\n", "\n" + IDENTATION)
    end

    def obj_to_string obj
      if obj.is_a? Exception
        backtrace = obj.backtrace || []
        %{\
#{obj.message}
  #{backtrace.join("\n  ")}
}
      else
        obj.to_s
      end
    end
end