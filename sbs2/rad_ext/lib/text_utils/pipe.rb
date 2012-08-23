class TextUtils::Pipe
  def initialize *processors
    @processor = processors.reverse.inject nil do |next_processor, meta|
      klass, args = if meta.is_a? Array
        [meta[0], meta[1..-1]]
      else
        [meta, []]
      end
      klass.new next_processor, *args
    end
  end

  def call text
    @processor.call text, {}
  end
end