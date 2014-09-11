require 'wgui/wgui'
require 'utils/open_constructor'
include WGUI

class Task
	include OpenConstructor
	attr_accessor :name, :completed	
end

class TaskEditor < WComponent
	attr_accessor :task
	
	def initialize parent
		super parent
		@name = TextField.new self, ""
		@completed = Select.new self, ['true', 'false']
		@ok = Button.new self, "Ok", self do
			task.name, task.completed = @name.text, @completed.selected == 'true'; 
			answer task 
        end
		@cancel = Button.new self, "Cancel" do
			answer
        end
		template 'xhtml/TaskEditor'
    end
	
	def render
		@name.text, @completed.selected = task.name, task.completed.to_s
    end	
end
 
class TaskView < WComponent
	attr_accessor :task, :on_edit, :on_delete
	
	def initialize parent
		super parent
		@name = Label.new self, ""
		@completed = Label.new self, ""
		@edit = Button.new(self, "Edit"){on_edit.call if on_edit}
		@delete = Button.new(self, "Delete"){on_delete.call if on_delete}
		template 'xhtml/TaskView'
    end
	
	def render
		@name.text, @completed.text= task.name, task.completed
    end
end
 
class MenuComponent < WComponent		
	def add(name, &action)
		Button.new self, name, &action
    end
end

class ListComponent < WComponent
	attr_accessor :filter, :items
	
	def initialize parent
		super parent
		self.items = [ 
			Task.new.set(:completed => false, :name => 'Missed task'), 
			Task.new.set(:completed => false, :name => 'Pending task'),
			Task.new.set(:completed => true, :name => 'Already completed task'),
			Task.new.set(:completed => false, :name => 'New task')
		]
		template "xhtml/ListComponent"
    end
	
	def render		
		childs.clear
		filtered_list = items.select{|item| filter ? filter.call(item) : true}
		filtered_list.each do |item|
			TaskView.new(self).set(
				:task => item,
				:on_edit => lambda {editor = TaskEditor.new(nil).set(:task => item); subflow(editor)},
				:on_delete => lambda{items.delete item; self.refresh}
			)							
		end
		Button.new self, 'New' do
			editor = TaskEditor.new(nil).set(:task => Task.new)
			subflow(editor){|new_task| self.items << new_task if new_task }	
		end		
	end
end

class Todo < WComponent		
	def initialize
		super
		@label = Label.new self, "ToDo Application Prototype"
		@menu = MenuComponent.new self
		@list = WContinuation.new(ListComponent.new(self))

		@menu.add('All'){@list.filter = lambda{true}; @list.refresh}
		@menu.add('Completed'){@list.filter = lambda{|item| item.completed}; @list.refresh}
		@menu.add('Not completed'){@list.filter = lambda{|item| !item.completed}; @list.refresh}	
		
		template 'xhtml/Todo'
	end	
end

if __FILE__.to_s == $0
	Runner.start Todo
	Runner.join
end