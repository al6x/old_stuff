module BrowserHelper
  class SingletonBrowser
    private :initialize
    attr_reader :browser

    def initialize;
      @browser = Browser.new
    end

    def self.instance name = ""
      @@self ||= nil
      unless @@self
        @@name = name
        @@self = SingletonBrowser.new
      end
      @@self
    end

    def self.close_instance name = ""
      @@self ||= nil
      return unless @@self && name == @@name

      instance.browser.close
      @@self = nil
    end
  end

  # Explicitly because it conflicts with Object.type

  def type *args
    SingletonBrowser.instance.browser.send :type, *args
  end

  # Explicitly because it conflicts with select method

  def select *args
    SingletonBrowser.instance.browser.send :select, *args
  end

  # Explicitly because it conflicts with Object.scope method

  def scope *args
    SingletonBrowser.instance.browser.send :scope, *args
  end

  # Explicitly because it conflicts with some method

  def open name = ""
    SingletonBrowser.instance name
  end

  def browser;
    SingletonBrowser.instance.browser
  end

  def method_missing(method_name, *args, &block)
    if method_name == :close
      SingletonBrowser.close_instance(*args)
    else
      unless proxy_methods.include? method_name.to_s
        raise NoMethodError,
                "undefined method `#{method_name}' for #{self.class}", caller
      end
#				super 
      browser.send method_name, *args, &block
    end
  end

  private

  def proxy_methods
    @proxy_methods ||= Browser.instance_methods.to_set.subtract(Browser.superclass.instance_methods)
  end
end