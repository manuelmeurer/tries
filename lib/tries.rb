require 'tries/version'

class Integer
  def tries(options = {}, &block)
    attempts          = self
    exception_classes = Array(options[:on] || StandardError)

    begin
      return yield
    rescue *exception_classes
      retry if (attempts -= 1) > 0
    end

    yield
  end
end
