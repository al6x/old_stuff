#
# Rack doesn't works well with ruby 1.9.2
# there's no :each method in String anymore
#
class Rack::Response
  def each(&callback)
    if @body.is_a? String
      @body.each_char(&callback)
    else
      @body.each(&callback)
    end
    @writer = callback
    @block.call(self)  if @block
  end
end