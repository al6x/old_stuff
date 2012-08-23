rspec do
  def self.with_view_path *args
    list = if args.first.is_a? Array
      args.first
    else
      args
    end

    before do
      rad.template
      list.each{|path| rad.template.paths << path}
    end

    after do
      list.each{|path| rad.template.paths.delete path}
    end
  end
end