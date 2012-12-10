require 'tries/version'

class Integer
  def tries(options = {}, &block)
    attempts          = self
    exception_classes = Array(options[:on] || StandardError)
    delay             = options[:delay]

    begin
      return yield
    rescue *exception_classes
      Kernel.sleep delay if delay
      retry if (attempts -= 1) > 0
    end

    yield
  end
end
