require 'WGUI/web_spec'
module WGUI
  module ComponentWigetSpec
    class Editor < WComponent
      children :@title, :@label, :@value, :@save
      def initialize
        super
        @title = Label.new ""
        @label = Label.new "Edit"
        @value = TextField.new ""
        @save = Button.new('Save', self){answer @value.text}
      end
      
      def title= title
        @title.text = title
      end
    end
    
    class View < WComponent
      attr_accessor :editor
      children :@label, :@multi, :@one
      def initialize
        super
        @label = Label.new 'Value'
        @multi = Button.new('Multistep Edit') do
          editor.title = 'Step 1'
          subflow(editor) { |first|
            editor.title = 'Step 2'
            subflow(editor){ |second|
              editor.title = 'Step 3'
              subflow(editor){ |third|
                @label.text = "Value " +first+second+third
                @label.refresh
              }
            }
          }
        end
        @one = Button.new('Onestep Edit') do
          editor.title = 'Step 1'
          subflow(editor) { |result|
            @label.text = "Value "+ result
            @label.refresh
          }
        end
      end
    end
    
    class Sample < WComponent
      children :@view
      def initialize
        super
        @view = WContinuation.new(View.new)
        @view.editor = Editor.new
      end
    end
    
    register_wiget "Continuation Sample" do
      Sample.new
    end
    
    class Main < WComponent
      class InnerPanel < WComponent
        children :@label
        def initialize
          @label = Label.new 'Main->InnerPanel'
        end
      end
      
      attr_accessor :two
      children :@ip, :@b
      def initialize
        super
        @ip = InnerPanel.new
        @b = Button.new( "To Substitute"){ subflow(two) }
      end
    end
    
    class Substitute < WComponent
      class InnerPanel < WComponent
        children :@label
        def initialize
          @label = Label.new 'Substitute->InnerPanel'
        end
      end
      
      children :@ip, :@b
      def initialize
        super
        @ip = InnerPanel.new
        @b = Button.new("To Main"){answer}
      end
    end
    
    register_wiget "should correct render children after subflow and resuming" do
      main = WContinuation.new(Main.new)
      main.two = Substitute.new
      main
    end
    
    describe "ComponentWiget" do							
      it "should support continuation" do				
        go 'localhost:8080/ui?t=Continuation Sample'
        click(/Onestep Edit/)
        wait_for.should have_text('Step 1')
        type :text => '456', :nearest_to => 'Edit'      
        click(/Save/)
        wait_for.should have_text(/Value/)
        wait_for.should have_text(/456/)
      end
      
      #		it "should cancel not finished workflow" do
      #			raise "Not implemented! (Add spec for WContinuation.cancel)"
      #        end
      
      it "Should correct refresh page during AJAX Continuation process" do
        go 'localhost:8080/ui?t=Continuation Sample'
        click(/Onestep Edit/)
        wait_for.should have_text('Step 1')
        refresh
        sleep 1
        wait_for.should have_text(/Edit/)
        type :text => '234', :nearest_to => 'Edit'   	
        click(/Save/)			
        wait_for.should have_text(/Value/)
        wait_for.should have_text(/234/)
      end
      
      it "should support multistep continuation" do
        go 'localhost:8080/ui?t=Continuation Sample'
        click(/Multistep Edit/)
        wait_for.should have_text('Step 1')
        type :text => 1, :nearest_to => 'Edit'      
        click(/Save/)
        wait_for.should have_text('Step 2')
        type :text => 2, :nearest_to => 'Edit'      
        click(/Save/)
        wait_for.should have_text('Step 3')
        type :text => 3, :nearest_to => 'Edit'      
        click(/Save/)			
        wait_for.should have_text(/Value/)
        wait_for.should have_text(/123/)
      end						
      
      it "should correct render children after subflow and resuming" do				
        go 'localhost:8080/ui?t=should correct render children after subflow and resuming'
        wait_for.should have_text(/Main->InnerPanel/)
        click(/To Substitute/)
        wait_for.should have_text(/Substitute->InnerPanel/)
        click(/To Main/)
        wait_for.should have_text(/Main->InnerPanel/)
      end
      
      #		class SFTwo < WComponent
      #			children :@label, :@edit, :@answer
      #	
      #			def initialize
      #				super 
      #				@label = Label.new "SFTwo"
      #				@edit = Button.new "Edit 2" do
      #					editor = Editor.new
      #					editor.title = "Editor"
      #					subflow(editor){|value| @label.text ="SFTwo, Value= #{value}"}
      #				end
      #				@answer = Button.new("Answer") {answer "value from SFTwo"}
      #			end
      #		end
      #		
      #		class SFOne < WComponent
      #			children :@label, :@edit1, :@edit2
      #	
      #			def initialize
      #				super
      #				@label = Label.new "SFOne"
      #				@edit1 = Button.new "Edit in the same continuation" do
      #					subflow(SFTwo.new){|value| @label.text = "SFOne, Value = #{value}"}
      #                end
      #				
      #				@edit2 = Button.new "Edit in another continuation" do
      #					p = WContinuation.new(WContinuation.new(SFTwo.new))
      #					subflow(p){|value| @label.text = "SFOne, Value = #{value}"}
      #                end
      #            end
      #        end
      #				
      #		it "One continuation inside another" do
      #			set_wiget WContinuation.new(WContinuation.new(SFOne.new))
      #			
      #			go 'localhost:8080'
      #			wait_for.should have_text('SFOne')			
      #			click 'Edit in another continuation'
      #			wait_for.should have_text('SFTwo')
      #			click 'Answer'
      #			wait_for.should have_text("SFOne, Value = value from SFTwo")		
      #			click 'Edit in another continuation'
      #			wait_for.should have_text('SFTwo')
      #			click "Edit 2"
      #			wait_for.should have_text('Editor')
      #			type "Edit" => "word"
      #			click 'Save'
      #			wait_for.should have_text('SFTwo, Value= word')
      #			click 'Answer'
      #			wait_for.should have_text('SFOne, Value = value from SFTwo')			
      #        end
      #		
      #				class InnerPortlet < WComponent
      #					include WPortlet
      #					def initialize p
      #						super p
      #						Label.new self, "InnerPortlet"				
      #		            end
      #					
      #					def render
      #						@state = {'name' => 'value'}
      #		            end
      #		        end				
      #				
      #				class Sample2 < WComponent
      #					def initialize
      #						super
      #						Label.new self, "View"
      #						InnerPortlet.new self
      #						Button.new(self, "Subflow"){subflow Editor.new(nil)}
      #		            end
      #		        end
      #				
      #				it "Should correct save state, when WComponent with inner Portlet is interrupted" do
      #					set_wiget WContinuation.new(Sample2.new)
      #					
      #					go 'localhost:8080'
      #					wait_for.should have_text('InnerPortlet')
      #					uri.should =~ /name\/value/
      #					click 'Subflow'
      #					wait_for.should have_text('Edit')
      #					go 'localhost/name2/value2'
      #					wait_for.should have_text('Edit')
      #					uri.should =~ /name\/value/
      #					click "Save"
      #					wait_for.should have_text("InnerPortlet")
      #		        end
      
      #				class Sample3 < WComponent
      #					def initialize
      #						super
      #						Label.new "View"
      #						@continuation = WContinuation.new(InnerPortlet.new(self))
      #						@stop_it = false
      #						Button.new(self, "External call for Subflow") do
      #							@continuation.subflow Editor.new(nil)
      #							@stop_it = false
      #		                end
      #						Button.new(self, "External call for Answer") do
      #							@stop_it = true
      #		                end
      #		            end
      #					
      #					def render
      #						@continuation.answer if @stop_it
      #					end
      #		        end
      #				
      #				it "Should resume Continuation during GET reqest" do
      #					set_wiget Sample3.new
      #					
      #					go 'localhost:8080'
      #					wait_for.should have_text('InnerPortlet')
      #					click "External call for Subflow"
      #					wait_for.should have_text('Edit')
      #					click "External call for Answer"
      #					wait_for.should have_text('InnerPortlet')
      #					uri.should =~ /name\/value/
      #		        end
      #
      #		class Sample4 < WComponent
      #			children :@l, :@c1, :@c2
      #			
      #			def initialize
      #				super
      #				@l = Label.new "Sample4"
      #				@c1 = WContinuation.new(InnerPortlet.new)				
      #				@c2 = WContinuation.new(InnerPortlet.new)				
      #				Button.new( "Start Subflow 1") do
      #					@c1.subflow Editor.new
      #                end
      #				Button.new( "Start Subflow 2") do
      #					@c2.subflow Editor.new
      #                end
      #            end
      #        end
      #
      #		it "Should support two Continuations in different places simultaneously" do
      #			set_wiget Sample4.new
      #			
      #			go 'localhost:8080'
      #			uri.should =~ /name\/value.+name\/value/
      #			click "Start Subflow 2"			
      #			wait_for.should have_text('Edit')
      #			uri.should =~ /name\/value.+name\/value/
      #			click "Start Subflow 1"
      #			wait_for{!has_text?('InnerPortlet')}
      #			uri.should =~ /name\/value.+name\/value/
      #			click :button => "Save", :nearest_to => 'Sample4'
      #			wait_for.should have_text('InnerPortlet')
      #			uri.should =~ /name\/value.+name\/value/
      #			click "Save"
      #			wait_for{!has_text?('Edit')}
      #			uri.should =~ /name\/value.+name\/value/			
      #        end			
    end
  end
end