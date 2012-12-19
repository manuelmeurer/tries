# Tries

[![Build Status](https://secure.travis-ci.org/krautcomputing/tries.png)](http://travis-ci.org/krautcomputing/tries)
[![Dependency Status](https://gemnasium.com/krautcomputing/tries.png)](https://gemnasium.com/krautcomputing/tries)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/krautcomputing/tries)

Solidify your code and retry on petty exceptions.

Read the accompanying [blog post](http://www.krautcomputing.com/blog/2012/12/19/new-gem-tries/).

## Requirements

Requires Ruby 1.9.2 or higher

## Is it production ready?

Yes! I have been using this code in numerous applications for several years.

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

```ruby
# Helper code to explain how it works

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

```ruby
# Rescue all errors
4.tries do
  method_that_raises_exception
end

=> Counter is 1
=> Counter is 2
=> Counter is 3
=> Counter is 4
=> Counter is 5
=> You made it through!
```

```ruby
# Rescue a specific error
3.tries on: FooError do
  method_that_raises_exception
end

=> Counter is 1
=> Counter is 2
=> Counter is 3
=> BarError: BarError
```

```ruby
# Rescue multiple errors
3.tries on: [FooError, BarError] do
  method_that_raises_exception
end

=> Counter is 1
=> Counter is 2
=> Counter is 3
=> Counter is 4
=> StandardError: StandardError
```

```ruby
# Delay execution after error
# "delay" parameter is in seconds, fractions are possible
4.tries delay: 1.5 do
  method_that_raises_exception
end

=> Counter is 1
waits 1.5 seconds...
=> Counter is 2
waits 1.5 seconds...
=> Counter is 3
waits 1.5 seconds...
=> Counter is 4
waits 1.5 seconds...
=> Counter is 5
=> You made it through!
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
