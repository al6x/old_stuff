class Browser
  def initialize
    @adapter = SeleniumAdapter.new
    @text_default, @check_default, @select_default = :from_right_of,
            :from_left_of, :from_right_of
    @scopes = {}
  end

  def close;
    @adapter.close
  end

  def go url;
    validate url, [String], 'URL'
    url = (url =~ /(^http:)|(^file:)/) ? url : "http://#{url}"
    @adapter.go url rescue raise_without_self "URL '#{url}' is not avaliable!", HOWT
  end

  def go_back;
    @adapter.go_back
  end

  def refresh;
    @adapter.refresh
  end

  def uri;
    CGI.unescape(@adapter.selenium.get_location)
  end

  def html;
    @adapter.selenium.get_html_source
  end

  def has_text? text
    if @wait_for
      timeout = @wait_for
      @wait_for = nil
      return SeleniumAdapter.wait_for(timeout) {has_text? text}
    end

    validate text, [String, Regexp], 'Text'
    return @adapter.count_of_elements(text, ['any']) > 0
  end

  # Click on element specified by Text or Fuzzy Search
  #
  # click 'Control Text'
  #
  # click [:any | :link | :button] => 'Control Text',
  # [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] => 'Text'

  def click *params
    raise_without_self "Parameters are not specified!", HOWT if params.empty?
    params = params[0]
    if single_term? params
      validate params, [String, Regexp], 'Control Text'
      @adapter.click params
    elsif params.is_a? Hash
      opt = OpenStruct.new(:control_text => nil, :control_types => [])
      if params.has_key? :link
        opt.control_types = [:link]
        opt.control_text = params[:link]
      elsif params.has_key? :button
        opt.control_types = [:button]
        opt.control_text = params[:button]
      elsif params.has_key? :any
        opt.control_types = [:link, :button]
        opt.control_text = params[:any]
      end

      raise_without_self "Control Type is not defined!", HOWT if opt.control_types.empty?
      validate opt.control_text, [String, Regexp], 'Control Text'

      parse_metric params, opt

      @adapter.fuzzy_click opt
    else
      raise_without_self "Invalid parameters. Should be Text or Fuzzy Search parameters!", HOWT
    end
  end

  # Does page has specified Element.
  #
  # has_element? :[button, link, textfield, textarea, select, radiobutton, checkbox, file, text, any] => 'Label

  def has_element? *params
    if @wait_for
      timeout = @wait_for
      @wait_for = nil
      return SeleniumAdapter.wait_for(timeout) {has_element?(*params)}
    end

    count(*params) > 0
  end

  # Shortcut for has_element? for RSpec.

  def has_the? *params;
    has_element?(*params)
  end

  # Count of specified Elements.
  #
  # count 'Text' -> shortcut for -> count :text => 'Text'
  #
  # count :[button, link, textfield, textarea, select, radiobutton, checkbox, file, text, any] => 'Label'

  def count *params
    if @wait_for
      timeout = @wait_for
      @wait_for = nil
      return SeleniumAdapter.wait_for(timeout) {count(*params)}
    end

    type, label = parse_element_type params
    return @adapter.count_of_elements(label, [type])
  end

  # Scope of workarea. All Browser operations can 'see' only this area.
  #
  # Defines scope:
  # scope :left => [:text, 'left'], :right => [:text, 'right'],
  #			:top => [:text, 'top'], :bottom => [:text, 'bottom']
  #
  # Defines scope (gives it name "Central Cell" so in the future you can enable it by name):
  # scope :name => 'Central Cell', :left => 'left', :right => 'right', :top => 'top', :bottom => 'bottom'
  #
  # Enable defined earlier scope:
  # scope 'Central Cell'
  # scope :CentralCell
  #
  # Defines scope (top and bottom are not bounded):
  # scope :left => 'left', :right => 'right'
  #

  def scope *params
    raise_without_self "Parameters are not specified!", HOWT if params.empty?
    params = params[0]
    if params.is_a?(String) || params.is_a?(Symbol)
      raise_without_self "Scope '#{params}' not defined!", HOWT unless @scopes.has_key? params
      @adapter.scope @scopes[params]
      return
    end

    raise_without_self "Invalid parameters. Should be Scope Name or Scope Definition!", HOWT unless params.is_a? Hash

    scope = []
    [:left, :right, :top, :bottom].each do |side|
      if params.has_key? side
        element = params[side]

        # reduce to full form
        element = [:text, element] unless element.is_a? Array

        # parse full form
        raise_without_self "Incorrect element specification: '#{element}'!", HOWT if element.size != 2
        type, label = parse_element_type([element[0] => element[1]])
        scope << [type, label]
      else
        scope << []
      end
    end

    scope_name = params[:name]
    if scope_name
      validate scope_name, [String, Symbol], 'Scope Name'
      @scopes[scope_name] = scope
    end

    @adapter.scope scope
  end

  # Clear scope, i.e. there will be no more any boundaries.

  def clear_scope;
    @adapter.clear_scope
  end

  # Returns value of TextField or TextArea specified by Text or Fuzzy Search
  #
  # text 'Label'
  #
  # text [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] => 'Label'

  def text *params
    raise_without_self "Parameters are not specified!", HOWT if params.empty?
    params = params[0]

    # reduce short form to full
    params = {@text_default => params} if single_term? params

    # parse full form
    opt = OpenStruct.new(:control_text => nil)
    parse_metric params, opt

    return @adapter.text(opt)
  end

  # Type text in TextField, TextArea or FileInput specified by Text or Fuzzy Search
  #
  # type 'Label' => 'Value'
  #
  # text :text => 'Value',
  #	[:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] => 'Label'

  def type *params
    raise_without_self "Parameters are not specified!", HOWT if params.empty?
    params = params[0]
    unless params.is_a?(Hash) && params.size > 0
      raise_without_self "Invalid parameters. Should be Text or Fuzzy Search parameters!", HOWT
    end

    # reduce short form to full
    params = {@text_default => params.keys[0], :text => params.values[0]} if params.size == 1


    # parse full form
    opt = OpenStruct.new(:control_text => nil)
    value = params[:text]
    parse_metric params, opt

    raise_without_self "Value cannot be 'nil'", HOWT unless value

    return @adapter.type(opt, value.to_s)
  end

  # Returns if RadioButton or CheckBox specified by Text or Fuzzy Search is selected
  #
  # checked? 'Label'
  #
  # checked? [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] => 'Label'

  def checked? *params
    if @wait_for
      timeout = @wait_for
      @wait_for = nil
      return SeleniumAdapter.wait_for(timeout) {checked?(*params)}
    end

    opt = parse_params_for_check params
    return @adapter.checked?(opt)
  end

  # Check RadioButton or CheckBox specified by Text or Fuzzy Search is selected
  #
  # check 'Label'
  #
  # check [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] => 'Label'

  def check *params
    opt = parse_params_for_check params
    @adapter.check opt, true
  end

  # Uncheck RadioButton or CheckBox specified by Text or Fuzzy Search is selected
  #
  # uncheck 'Label'
  #
  # uncheck [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] => 'Label'

  def uncheck *params
    opt = parse_params_for_check params
    @adapter.check opt, false
  end

  # Select options in Select and MultiSelect specified by Text or Fuzzy Search
  #
  # select 'Label' => 'Option'
  # select 'Label' => ['Option1', 'Option2']
  #
  # select :option => 'Option',
  #	[:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] => 'Label'
  # select :option => ['Option1', 'Option2'],
  #	[:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] => 'Label'

  def select *params
    raise_without_self "Parameters are not specified!", HOWT if params.empty?
    params = params[0]

    unless params.is_a?(Hash) && params.size > 0
      raise_without_self "Invalid parameters. Should be Text or Fuzzy Search parameters!", HOWT
    end

    # reduce to full form
    params = {@select_default => params.keys[0], :option => params.values[0]} if params.size == 1

    # parse full form
    opt = OpenStruct.new(:control_text => nil)
    options = params[:option]
    parse_metric params, opt

    raise_without_self "Options cannot be 'nil'", HOWT unless options
    options = options.is_a?(Array) ? options : [options]
    options.each do |o|
      unless o.is_a? String
        raise_without_self "Options should be 'String' or 'Array of String' but is the '#{o.class.name}'!", HOWT
      end
    end

    return @adapter.select(opt, options)
  end

  # Unselect options in Select and MultiSelect specified by Text or Fuzzy Search
  #
  # unselect 'Label'
  #
  # unselect [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] => 'Label'

  def unselect *params
    opt = parse_params_for_select params
    return @adapter.unselect(opt)
  end

  # Returns value of Select or Multiselect specified by Text or Fuzzy Search
  #
  # selection 'Label'
  #
  # selection [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of] => 'Label'

  def selection *params
    opt = parse_params_for_select params
    return @adapter.selection(opt)
  end

  # Default metric for TextElements
  # text_default [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of]

  def text_default metric;
    @text_default = metric
  end

  # Default metric for Radio/Check Buttons
  # check_default [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of]

  def check_default metric;
    @check_default = metric
  end

  # Default metric for Select/MultiSelect
  # select_default [:nearest_to | :from_top_of | :from_bottom_of | :from_left_of | :from_right_of]

  def select_default metric;
    @select_default = metric
  end

  # Waits for condition.call == true during timeout. If timeout not specified, it waits for default timeout.
  # If condition not specified, next call to Browser will be waiting (for utility usage with RSpec).
  #TODO create shortcut, wait_for('fuck') => wait_for.should have_text('fuck')

  def wait_for timeout = 0, &condition
    if condition
      SeleniumAdapter.wait_for(timeout, &condition)
      return nil
    else
      @wait_for = timeout
      return self
    end
  end

  private
  # validate params, [String, Symbol], 'Should be String or Symbol'

  def validate expression, types, pname
    raise_without_self "#{pname} should not be nil!", HOWT unless expression
    "#{pname} should not be empty!" if expression.to_s.empty?
    unless types.include? expression.class
      raise_without_self "#{pname} should be #{types} but is '#{expression.class.name}'!", HOWT
    end
  end

  def parse_params_for_check params
    raise_without_self "Parameters are not specified!", HOWT if params.empty?
    params = params[0]

    # reduce to full form
    params = {@check_default => params} if single_term? params

    # parse full form
    opt = OpenStruct.new(:control_text => nil)
    parse_metric params, opt

    return opt
  end

  def parse_params_for_select params
    raise_without_self "Parameters are not specified!", HOWT if params.empty?
    params = params[0]

    # reduce to full form
    params = {@select_default => params} if single_term? params

    # parse full form
    opt = OpenStruct.new(:control_text => nil)
    parse_metric params, opt

    return opt
  end

  def single_term? params
    params.is_a?(String) || params.is_a?(Regexp)
  end

  # 'Text' or {:type => 'Text'}

  def parse_element_type params
    raise_without_self "Parameters are not specified!", HOWT if params.empty?
    params = params[0]

    # reduce to full form
    params = {:any => params} if single_term? params

    # parse full form
    unless params.is_a?(Hash) && params.size == 1
      raise_without_self "Invalid parameters. Should be  {'Type' => 'Label'} pair!", HOWT
    end

    all_types = [:button, :link, :textfield, :textarea, :select, :radiobutton, :checkbox, :file, :text, :any]
    all_types.each do |t|
      if params.has_key? t
        label = params[t]
        validate label, [String, Regexp], 'Label'
        return t, label
      end
    end
    raise_without_self "Type is not defined! Avaliable Types are: [#{all_types}]).", HOWT
  end

  def parse_metric params, opt
    unless params.is_a? Hash
      raise_without_self "Invalid parameters. Should be Text or Fuzzy Search parameters!", HOWT
    end

    all_metric_types = [:nearest_to, :from_top_of, :from_bottom_of, :from_left_of, :from_right_of]
    all_metric_types.each do |type|
      if params.has_key? type
        opt.metric = type
        opt.text = params[type]
        break
      end
    end

    validate opt.text, [String, Regexp], 'Text for Text Element'
    raise_without_self "Metric is not defined (Avaliable metric are: [#{all_metric_types}])!", HOWT unless opt.metric
  end
end