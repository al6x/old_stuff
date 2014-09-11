class Storage
	
	LOCK = "lock"
	OBJECTS = "objects"
	JOURNAL = "journal"
	STATE = "state"	
	
	def initialize name, basedir
		raise "Directory doesn't exists '#{basedir}'!" unless File.exist? basedir
		@path = File.join(basedir.gsub("\\", '/'), name.to_s)
        
		Dir.mkdir @path unless File.exist? @path
		Dir.mkdir File.join(@path, OBJECTS) unless File.exist? File.join(@path, OBJECTS)
		
		lock
		@journal = File.new(File.join(@path, JOURNAL), "a+")
		@state = AtomicState.new File.join(@path, STATE)        
		check_and_force_atomicity
	end
    
	def instance_variable_set *par
		p :set
	end
			
	def [] id
		begin
			File.open(File.join(@path, OBJECTS, id.to_s)) do |f|
				return f.read
			end
		rescue Exception => e
			if e.message =~ /No such file or directory/
				raise NotFound, "Data with id '#{id}' not found!", caller
			else
				raise e
			end
		end
	end
	
	def []= id, value
		atomic_write(id => value)
	end
	
	def delete id
		File.delete File.join(@path, OBJECTS, id.to_s)
	end
	
	def clear
		FileUtils.rm Dir.glob(File.join(@path, OBJECTS, "*"))
	end
	
	def close
		@journal.close
		@state.close
		unlock
	end
	
	def size 	
		Dir.glob(File.join(@path, OBJECTS, "*")).size 
	end
	
	def list_of_ids
		Dir.glob(File.join(@path, OBJECTS, "*")).collect{|name| File.basename name}
	end
	
	def atomic_write hash	
		objects = {}
		hash.each do |name, data| 
			objects[File.join(@path, OBJECTS, name.to_s)] = data			
		end
						
		@journal.truncate 0			
		hash.each_key{|name| @journal.puts name}
		@journal.flush
		@state.state = AtomicState::WRITE
			
		# Backup
		objects.each_key do |name|								
			File.rename name, "#{name}.bak" if File.exist? name
		end						

		begin
			objects.each do |name, data|
				File.open(name, 'wb') do |f|
					f.write data
				end
			end
		rescue Exception => e
			objects.each_key do|name|
				File.delete name if File.exist? name
			end

			objects.each_key do |name|
				backup = "#{name}.bak"
				File.rename backup, name  if File.exist? backup
			end

			raise e
		end
			
		@state.state = AtomicState::DELETE
			
		objects.each_key do|name| 
			backup = "#{name}.bak"
			File.delete backup if File.exist? backup
		end
			
		@state.state = AtomicState::FINISHED
	end
	
	def self.delete name, basedir
		path = File.join(basedir, name.to_s)
		FileUtils.rm_rf path if File.exist? path
	end
			
	protected
	def lock
		@lock = File.new(File.join(@path, LOCK), "w")
		unless @lock.flock File::LOCK_EX | File::LOCK_NB
			@lock.close
			raise "Can't open #{@name}, it's alredy opend!" 
		end
	end
	
	def unlock
		@lock.flock File::LOCK_UN
		@lock.close
	end
	
	def check_and_force_atomicity								
		if @state.state == AtomicState::WRITE
			@journal.each_line do |name|
				name = File.join(@path, OBJECTS, name)
				backup = "#{name}.bak"
				File.delete name if File.exist? name
				File.rename(backup, name) if File.exist? backup
			end
		elsif @state.state == AtomicState::DELETE
			@journal.each_line do |name|
				backup = "#{name}.bak"
				File.delete backup if File.exist? backup
			end
		end
		@state.state == AtomicState::FINISHED
	end
end