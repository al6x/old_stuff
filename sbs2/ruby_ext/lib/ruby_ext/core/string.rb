class String
  def indent spaces = 2
    indent = ' ' * spaces
    gsub /^/, indent
  end

  def rsplit *args
    reverse.split(*args).collect(&:reverse).reverse
  end

  def dirname
    File.expand_path(File.dirname(self))
  end

  def expand_path
    File.expand_path(self)
  end

  def to_a
    [self]
  end

  def underscore
    word = self.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end

  def camelize first_letter_in_uppercase = true
    if first_letter_in_uppercase
      gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      self[0].chr.downcase + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end

  def constantize
    names = sub(/^::/, '').split '::'
    names.reduce(Object){|memo, name| memo.const_get name, false}
  end

  def substitute(*args)
    gsub(*args){yield Regexp.last_match.captures}
  end

  def substitute!(*args)
    gsub!(*args){yield Regexp.last_match.captures}
  end

  alias_method :blank?, :empty?
end