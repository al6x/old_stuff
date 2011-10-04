module AbstractInterface
  module FormBuilders
    class ThemedFormTagBuilder
      include AbstractFormBuilder
  
      attr_reader :template

      def initialize template
        @template = template
      end
    end
  end
end