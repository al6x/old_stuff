class Micon::Core
  def register_extension name, &block
    name.must.be_a Symbol
    block.must.be_defined

    raise "extension :#{name} already registered!" if extensions.include? name

    extensions[name] = block
  end

  def extension name, target = nil, *args, &default_extension
    name.must.be_a Symbol

    if block = extensions[name] || default_extension
      target ? target.instance_exec(*args, &block) : block.call(*args)
    end
  end

  def extensions; @extensions ||= {} end
end