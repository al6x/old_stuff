require 'spec'
require 'utils/stack_trace'

module Utils
    describe 'StackTrace' do
        it do
            stack = [
                "U:\\workspace\\projects\\DX/utils/class_auto_loader.rb:101:in `synchronize'", 
                "U:\\workspace\\projects\\DX/utils/class_auto_loader.rb:83:in `load_class'", 
                "U:\\workspace\\projects\\DX/utils/class_auto_loader.rb:128:in `const_missing'", 
                "U:\\workspace\\projects\\DX\\OG\\scripts\\spec\\serializer_and_entity_helper_spec.rb:23", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_methods.rb:78:in `instance_eval'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_methods.rb:78:in `run_with_description_capturing'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_methods.rb:19:in `execute'", 
                "U:/workspace/soft/ruby/lib/ruby/1.8/timeout.rb:48:in `timeout'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_methods.rb:16:in `execute'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_group_methods.rb:292:in `execute_examples'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_group_methods.rb:291:in `each'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_group_methods.rb:291:in `execute_examples'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_group_methods.rb:121:in `run'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/runner/example_group_runner.rb:22:in `run'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/runner/example_group_runner.rb:21:in `each'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/runner/example_group_runner.rb:21:in `run'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/runner/options.rb:90:in `run_examples'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/runner/command_line.rb:19:in `run'", 
                "U:\\workspace\\soft\\ruby\\lib\\ruby\\gems\\1.8\\gems\\rspec-1.1.3\\bin\\spec:4", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/ruby-debug-ide-0.1.10/lib/ruby-debug.rb:90:in `debug_load'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/ruby-debug-ide-0.1.10/lib/ruby-debug.rb:90:in `main'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/ruby-debug-ide-0.1.10/bin/rdebug-ide:74", 
                "U:/workspace/soft/ruby/bin/rdebug-ide:16:in `load'", 
                "U:/workspace/soft/ruby/bin/rdebug-ide:16"                
            ]
            file = "U:\\workspace\\projects\\DX/utils/class_auto_loader.rb"
            result = StackTrace.remove_self stack, file
            result.should == [
                "U:\\workspace\\projects\\DX\\OG\\scripts\\spec\\serializer_and_entity_helper_spec.rb:23", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_methods.rb:78:in `instance_eval'",
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_methods.rb:78:in `run_with_description_capturing'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_methods.rb:19:in `execute'", 
                "U:/workspace/soft/ruby/lib/ruby/1.8/timeout.rb:48:in `timeout'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_methods.rb:16:in `execute'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_group_methods.rb:292:in `execute_examples'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_group_methods.rb:291:in `each'",
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_group_methods.rb:291:in `execute_examples'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/example/example_group_methods.rb:121:in `run'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/runner/example_group_runner.rb:22:in `run'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/runner/example_group_runner.rb:21:in `each'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/runner/example_group_runner.rb:21:in `run'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/runner/options.rb:90:in `run_examples'", 
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/rspec-1.1.3/lib/spec/runner/command_line.rb:19:in `run'", 
                "U:\\workspace\\soft\\ruby\\lib\\ruby\\gems\\1.8\\gems\\rspec-1.1.3\\bin\\spec:4",
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/ruby-debug-ide-0.1.10/lib/ruby-debug.rb:90:in `debug_load'",
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/ruby-debug-ide-0.1.10/lib/ruby-debug.rb:90:in `main'",
                "U:/workspace/soft/ruby/lib/ruby/gems/1.8/gems/ruby-debug-ide-0.1.10/bin/rdebug-ide:74", 
                "U:/workspace/soft/ruby/bin/rdebug-ide:16:in `load'",
                "U:/workspace/soft/ruby/bin/rdebug-ide:16"
                
            ]
        end
    end
end