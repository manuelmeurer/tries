require 'tries/version'
require 'gem_config'

module Tries
  include GemConfig::Base

  with_configuration do
    has :on_error, classes: Proc
  end
end

class Integer
  def tries(options = {}, &block)
    attempts          = 1
    exception_classes = Array(options[:on] || StandardError)
    delay             = options[:delay]
    incremental       = options[:incremental]

    begin
      return yield
    rescue *exception_classes => exception
      next_delay = calculate_delay(delay, attempts, incremental) if delay
      Tries.configuration.on_error.call(exception, attempts, next_delay) if Tries.configuration.on_error
      options[:on_error].call(exception, attempts, next_delay) if options[:on_error]
      Kernel.sleep next_delay if delay
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
