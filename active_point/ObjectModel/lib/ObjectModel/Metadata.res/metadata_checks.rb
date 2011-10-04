[
lambda do |klass, meta|
	a = meta.attributes.keys.to_set
	c = meta.children.keys.to_set
	r = meta.references.keys.to_set
	dup = (a & c) + (a & r) + (c & r)
	raise "The same name '#{dup.inspect}' used for attribute/child/reference definition!" unless dup.empty?
end,
]