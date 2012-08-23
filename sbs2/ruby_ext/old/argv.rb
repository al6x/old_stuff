#
# Parsing command line
#
module RubyExt
  def self.argv input = ARGV
    # don't want to modify original input and can't use :clone (it may be not an array)
    input = input.collect{|v| v}

    list, options = [], {}
    until input.empty? do
      arg = input.shift.strip
      if arg =~ /.+:$/ and !input.empty?
        k = arg[0..-2].to_sym
        v = input.shift
        v = v.sub(/\s*,$/, '') if v
        options[k] = simple_cast(v)
      else
        v = arg.gsub(/^['"]|['"]$/, '')
        v = v.sub(/\s*,$/, '')
        list << simple_cast(v)
      end
    end
    list << options
    list
  end

  protected
    def self.simple_cast v
      if v =~ /^:[a-z_0-9]+$/i
        v[1..-1].to_sym
      elsif v =~ /^[0-9]+$/
        v.to_i
      elsif v =~ /^[0-9]*\.[0-9]+$/
        v.to_f
      elsif v =~ /^\/.+\/$/
        Regexp.new v[1..-2]
      elsif v == 'nil'
        nil
      else
        v
      end
    end
end