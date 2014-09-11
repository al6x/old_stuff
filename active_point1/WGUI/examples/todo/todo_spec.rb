require 'WGUI/scripts/web_spec'
require 'wgui/spec/examples/todo/todo_component'

describe 'ToDo' do
	before :all do 
		stop_webserver
		Runner.start Todo
    end
	after :all do 
		close
		Runner.stop
    end
	
	it 'should delete task' do
		go 'localhost'
		wait_for.should have_text('Pending task')    
		click :any => 'Delete', :from_right_of => 'Pending task'
		wait_for{!has_text?('Pending task')}
		should have_text('Missed task')
		should have_text('Already completed task')
		should have_text('New task')
	end
	
	it 'should display tasks' do		
		go 'localhost'
		should have_text('ToDo Application Prototype')
	end
	
	def create_task name, b = browser
		b.click 'New'
		b.type 'Name' => name
		b.select 'Completed' => 'true'
		b.click 'Ok'
	end
	
	it 'should support sessions' do
		go 'localhost'
		create_task 'ie1'
		wait_for.should have_text('ie1')
		
		b2 = HOWT::Browser.new
		b2.go 'localhost'
		b2.wait_for.should have_text('ToDo Application Prototype')
		b2.should_not have_text('ie1')
		create_task 'ie2', b2
		b2.wait_for.should have_text('ie2')
		
		should_not have_text('ie2')
	end
	
	it 'should add  tasks' do
		go 'localhost'
		create_task 'test_add'		
		wait_for.should have_text('test_add')		
	end
	
	it 'should edit task && correct works with refresh during continuation' do
		go 'localhost'
		
		click :button => 'Edit', :from_right_of => "Missed task"
		refresh
		wait_for{!has_text?('ToDo Application Prototype')}
		wait_for.should have_text('ToDo Application Prototype')
		type 'Name' => 'test_edit'
		select 'Completed' => 'true'
		click 'Ok'
		wait_for.should have_text('test_edit')
	end
end