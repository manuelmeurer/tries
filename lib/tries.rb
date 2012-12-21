require 'tries/version'

class Integer
  def tries(options = {}, &block)
    attempts          = 1
    exception_classes = Array(options[:on] || StandardError)
    delay             = options[:delay]
    incremental       = options[:incremental]

    begin
      return yield
    rescue *exception_classes
      Kernel.sleep calculate_delay(delay, attempts, incremental) if delay
      retry if (attempts += 1) <= self
    end

    yield
  end

  private
  def calculate_delay(delay, attempts, incremental)
    return delay unless incremental

    delay * attempts
  end
end
