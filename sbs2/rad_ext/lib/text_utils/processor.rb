class TextUtils::Processor
  def initialize next_processor = nil
    @next_processor = next_processor
  end

  protected
    def call_next data, env
      if @next_processor
        @next_processor.call data, env
      else
        data
      end
    end
end