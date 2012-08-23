require 'rake'
require 'fileutils'

#
# Code Coverage
#
# begin
#   require 'class_loader/tasks'
#
#   desc "Clean code coverage temporary files"
#   task clean: 'class_loader:clean' do
#     require 'fileutils'
#     FileUtils.rm_r '../*/coverage' if File.exist? '../*/coverage'
#   end
# rescue LoadError
# end

#
# Spec
#
begin
  require 'rspec/core/rake_task'
  task default: :spec
  task spec: 'spec:find_and_specs'

  namespace :spec do
    desc "Finds Specifications"
    task :find_and_specs do
      RSpec::Core::RakeTask.new('spec') do |t|
        t.pattern = "spec/**/[^_]*_spec.rb"
      end
    end

    desc "Run RSpec code exapmples in isolated mode (every spec file in another Ruby process)"
    task :isolated do
      Dir.glob("spec/[^_]**/[^_]*_spec.rb").each do |spec_file|
        Kernel.system "rspec #{spec_file}"
      end
    end
  end
rescue LoadError
  task :default do
    puts "default rake task is :rspec but there's no rspec gem installed, install it first"
  end
end

#
# before, after and remove task
#
def before task_name, &block
  $_task_counter ||= {}
  counter = ($_task_counter[task_name] ||= 0)
  before_task_name = "#{task_name}_before_#{counter}"

  task before_task_name, &block
  task task_name => before_task_name

  $_task_counter[task_name] += 1
end

def after task_name, &block
  task task_name, &block
end

def remove_task(task_name)
  Rake.application.instance_variable_get('@tasks').delete(task_name.to_s)
end
alias :delete_task :remove_task


#
# project
#
$_project_dir = (
  caller.find{|line| line =~ /\/Rakefile\:/} ||
  raise("You can include the 'rake_ext' only in Rakefile!")
).sub(/\/Rakefile\:.*/, '')
def project_dir
  $_project_dir
end

def project options = nil
  if options
    $_project = {}
    options.each{|k, v| $_project[k.to_sym] = v}

    $_project[:name] || raise("project name not defined")
    $_project[:official_name] ||= $_project[:name]

    require 'rake_ext/project'
  end
  $_project || raise("project not defined!")
end


#
# Docs
#
namespace :docs do
  desc "Generate documentation"
  task :generate do
    %x(cd docs && rocco -o site *.rb)
  end

  desc "Publish documentation"
  task :publish do
    require 'open3'
    require 'vfs'

    executor = Class.new do
      def run cmd, expectation = nil
        stdin, stdout, stderr = Open3.popen3 cmd
        stderr = stderr.read
        stdout = stdout.read

        if expectation and (stdout + stderr) !~ expectation
          puts stdout
          puts stderr
          raise "can't execute '#{cmd}'!"
        end
        stdout
      end
    end.new

    out = executor.run "git status", /nothing to commit .working directory clean/

    '.'.to_dir.tmp do |tmp|
      tmp.delete
      "docs/site".to_dir.copy_to tmp['site']

      executor.run "git checkout gh-pages", /Switched to branch 'gh-pages'/
      tmp['site'].copy_to '.'.to_dir
      executor.run "git add ."
      executor.run "git commit -a -m 'upd docs'", /upd docs/
      executor.run "git push", /gh-pages -> gh-pages/
      executor.run "git checkout master", /Switched to branch 'master'/
    end
  end
end