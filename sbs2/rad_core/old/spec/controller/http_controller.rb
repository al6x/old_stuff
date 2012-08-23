require 'rad/spec/controller'

RSpec.configure do |config|
  config.after :all do |context|
    context.wcall_options = {}
  end
end

rspec do
  def request
    rad.workspace.request
  end

  # def self.with_http_controller options = {}
  #   scope = options[:before] || :all
  #   prepare_params = options[:prepare_params]
  #
  #   with_controller options
  #
  #   unless prepare_params
  #     before scope do
  #
  #     end
  #   end
  # end

  WCALL_OPTIONS = [:controller]
  attr_writer :wcall_options
  def wcall_options; @wcall_options ||= {} end

  def set_wcall options
    invalid_options = options.keys - WCALL_OPTIONS
    raise "Unsupported options #{invalid_options}!" unless invalid_options.empty?

    self.wcall_options = options
  end

  def set_controller controller_class
    @controller_class = controller_class
    set_wcall controller: controller_class
  end

  def self.set_controller controller_class
    before{set_controller controller_class}
  end

  def wcall *args, &block
    workspace_variables, params = parse_wcall_arguments *args
    ccall nil, nil, params, workspace_variables, &block
  end

  def post_wcall *args, &block
    params = args.extract_options!
    raise "_method variable already set!" if params.include?(:_method) or params.include?('_method')
    wcall(*(args << params.merge(_method: 'post')), &block)
  end

  protected
    def parse_wcall_arguments *args
      # parsing params
      params = args.extract_options!
      first = args.first

      workspace_variables = {}
      if args.size == 1 and first.is_a?(String) and first =~ /^\/|^http:/
        uri = Uri.parse first
        workspace_variables[:path] = uri.path
        workspace_variables[:env] = Rad::Http::Request.stub_environment(first)

        # some params may be defined in :url ans some in :params, merging both
        params = uri.query_values.merge params if uri.query_values
      elsif (first.is_a?(String) or first.is_a?(Symbol)) and args.size <= 2
        workspace_variables[:path] = '/'
        workspace_variables[:class] = wcall_options[:controller] || raise("not defined wcall controller (use set_wcall controller: SomeController)!")
        workspace_variables[:method_name] = first
        workspace_variables.merge! args[1] if args.size > 1
      elsif first.is_a?(Class) and args.size <= 3
        workspace_variables[:path] = '/'
        workspace_variables[:class] = args[0]
        workspace_variables[:method_name] = args[1]
        workspace_variables.merge! args[2] if args.size > 2
      else
        raise "Invalid input!"
      end

      # preparing environment
      workspace_variables[:env] ||= {}
      workspace_variables[:env].reverse_merge! Rad::Http::Request.stub_environment

      # setting request method
      if request_method = params.delete(:_method) || params.delete('_method')
        request_method = request_method.to_s.upcase
        raise "invalid request method :#{request}" unless %w(GET POST PUT DELETE).include? request_method.
        raise "REQUEST_METHOD variable already set!" if workspace_variables[:env].include? 'REQUEST_METHOD'
        workspace_variables[:env]['REQUEST_METHOD'] = request_method
      end

      workspace_variables[:request] = Rad::Http::Request.new(workspace_variables[:env])

      return workspace_variables, params
    end
end