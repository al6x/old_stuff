class Path < String
	def initialize path = ''
		super path.chomp
		raise "Invalid Path '#{path}' (ends with the '/' sign)" if (self =~ /\/$/ ) && !empty?
		raise "Tnvalid Path '#{path}' (the '/' sign encounters multiple times in a row)" if self =~ /\/{2,}/
	end

	def absolute?;
		(self =~ /^\//) ? true : false
	end
	
	def relative?;
		!absolute?
	end

	def empty?; self == '' || self == '/' end

	def simple?;
		self =~ /^\/?[^\/]*$/ ? true : false
	end

	def after part
		raise "There is no Part '#{part}' in the Path '#{self}'" unless include? part
		Path.new((absolute? ? '/' : '') + sub(/.*#{part}\/*/, ""))
	end

	def before part
		raise "There is no Part '#{part}' in the Path '#{self}'" unless include? part
		Path.new((absolute? ? '/' : '') + to_relative.sub(/\/*#{part}.*/, ""))
	end

	def previous;
		return nil if empty?
		p = sub(/[^\/]+?$/, "" )
		p = p[0..p.string_size-2] if p.string_size > 1
		return p
	end

	def next;
		p = sub(/[^\/]+\/?/, "")
		return p.empty? ? nil : p
	end

	def first;
		Path.new(scan(/^\/?[^\/]*/)[0])
	end

	def last;
		Path.new(sub(/[^\/].+\//, ""))
	end

	def last_name
		list = scan(/[^\/]+$/)
		return list.size > 0 ? list[0] : nil
	end

	def first_name
		list = scan(/[^\/]+/)
		return list.size > 0 ? list[0] : nil
	end

	def add path
		path = Path.new(path) unless path.is_a? Path
		return Path.new((absolute? ? "/" : "") + path.to_relative) if empty?
		return Path.new(self) if path.empty?
		return Path.new(self.string_plus((path.absolute? ? '' : '/')) + path)
	end

	alias_method :string_plus, :+
		def + o
		add(o)
	end

	def to_absolute; Path.new(absolute? ? self : "/#{self}") end

	def to_relative; Path.new sub(/^\//, "") end

	alias_method :string_each, :each
	def each &block
		to_a.each(&block)
	end

	alias_method :string_size, :size
	def size() to_a.size end

	def to_a; @elements ||= to_relative.split('/') end

	def to_s
		return String.new(self)
	end
end