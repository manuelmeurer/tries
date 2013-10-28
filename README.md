# Tries

[![Gem Version](https://badge.fury.io/rb/tries.png)](http://badge.fury.io/rb/tries)
[![Build Status](https://secure.travis-ci.org/krautcomputing/tries.png)](http://travis-ci.org/krautcomputing/tries)
[![Dependency Status](https://gemnasium.com/krautcomputing/tries.png)](https://gemnasium.com/krautcomputing/tries)
[![Code Climate](https://codeclimate.com/github/krautcomputing/tries.png)](https://codeclimate.com/github/krautcomputing/tries)

Solidify your code and retry on petty exceptions.

Tries lets you retry a block of code multiple times, which is convenient for example when communicating with external APIs that might return an error the one second but work fine the next.

You can specify exactly how often the block of code is retried and which exceptions are caught.

Read the accompanying [blog post](http://www.krautcomputing.com/blog/2012/12/19/new-gem-tries/).

## Requirements

Ruby >= 1.9.2

## Installation

Add this line to your application's Gemfile:

    gem 'tries'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tries

## Usage

```ruby
3.tries on: Timeout::Error do
  Mechanize.new.get 'https://www.google.com/'
end
```

## Detailed usage

### Helper code to explain how it works

```ruby
FooError = Class.new(StandardError)
BarError = Class.new(StandardError)

@error_counter = 0

def method_that_raises_exception
  @error_counter += 1
  puts "Counter is #{@error_counter}"

  case @error_counter
  when 1 then raise FooError
  when 2 then raise FooError
  when 3 then raise BarError
  when 4 then raise StandardError
  end

  puts 'You made it through!'
end
```

### Rescue all errors

```ruby
4.tries do
  method_that_raises_exception
end

# => Counter is 1
# => Counter is 2
# => Counter is 3
# => Counter is 4
# => Counter is 5
# => You made it through!
```

### Rescue a specific error

```ruby
3.tries on: FooError do
  method_that_raises_exception
end

# => Counter is 1
# => Counter is 2
# => Counter is 3
# => BarError
```

### Rescue multiple errors

```ruby
3.tries on: [FooError, BarError] do
  method_that_raises_exception
end

# => Counter is 1
# => Counter is 2
# => Counter is 3
# => Counter is 4
# => StandardError
```

### Delay execution after error

`delay` is in seconds, fractions are possible

#### Static delay

```ruby
4.tries delay: 1.5 do
  method_that_raises_exception
end

# => Counter is 1
# waits 1.5 seconds...
# => Counter is 2
# waits 1.5 seconds...
# => Counter is 3
# waits 1.5 seconds...
# => Counter is 4
# waits 1.5 seconds...
# => Counter is 5
# => You made it through!
```

#### Incremental delay

```ruby
4.tries delay: 1.5, incremental: true do
  method_that_raises_exception
end

# => Counter is 1
# waits 1.5 seconds...
# => Counter is 2
# waits 3 seconds...
# => Counter is 3
# waits 4.5 seconds...
# => Counter is 4
# waits 6 seconds...
# => Counter is 5
# => You made it through!
```

### Callback on error

You can set a method or Proc to be called every time an exception occurs. Either set it globally in an initializer, e.g. to log all exceptions to a service like [Airbrake](https://airbrake.io/), or locally when calling `tries`. If both a global callback and a local callback are set, both are called, the global one first.

#### Global callback

```ruby
# config/initializers/tries.rb
Tries.configure do |config|
  config.on_error = lambda do |exception, attempts, next_delay|
    puts "Whow, a #{exception.class} just occurred! It was attempt nr. #{attempts} to do whatever I was doing."
    if next_delay
      puts "I'm gonna wait #{next_delay} seconds and try again."
    else
      puts "A delay was not configured so I'm gonna go for it again immediately."
    end
  end
end
```

```ruby
3.tries delay: 0.5, incremental: true do
  method_that_raises_exception
end

# => Counter is 1
# => Whow, a FooError just occurred! It was attempt nr. 1 to do whatever I was doing.
# => I'm gonna wait 0.5 seconds and try again.
# waits 0.5 seconds...
# => Counter is 2
# => Whow, a FooError just occurred! It was attempt nr. 2 to do whatever I was doing.
# => I'm gonna wait 1.0 seconds and try again.
# waits 1 second...
# => Counter is 3
# => Whow, a BarError just occurred! It was attempt nr. 3 to do whatever I was doing.
# => I'm gonna wait 1.5 seconds and try again.
# waits 1.5 seconds...
# => Counter is 4
# => StandardError
```

When using Rails, a global callback also lets you effectively disable Tries in development environment:

```ruby
# config/initializers/tries.rb
Tries.configure do |config|
  config.on_error = lambda do |exception, attempts, next_delay|
    raise exception if Rails.env.development?
  end
end
```

#### Local callback

```ruby
callback = lambda do |exception, attempts, next_delay|
  puts "Local callback! Exception: #{exception.class}, attempt: #{attempts}, next_delay: #{next_delay}"
end

3.tries delay: 0.5, incremental: true, on_error: callback do
  method_that_raises_exception
end

# => Counter is 1
# => Local callback! Exception: FooError, attempt: 1, next_delay: 0.5
# waits 0.5 seconds...
# => Counter is 2
# => Local callback! Exception: FooError, attempt: 2, next_delay: 1.0
# waits 1 second...
# => Counter is 3
# => Local callback! Exception: BarError, attempt: 3, next_delay: 1.5
# waits 1.5 seconds...
# => Counter is 4
# => StandardError
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
