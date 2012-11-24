# Tries

[![Build Status](https://secure.travis-ci.org/krautcomputing/tries.png)](http://travis-ci.org/krautcomputing/tries)
[![Dependency Status](https://gemnasium.com/krautcomputing/tries.png)](https://gemnasium.com/krautcomputing/tries)
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/krautcomputing/tries)

Solidify your code and retry on petty exceptions

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

@counter = 0

def method_that_raises_exception
  @counter += 1
  puts "Counter is #{@counter}"

  case @counter
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

> Counter is 1
> Counter is 2
> Counter is 3
> Counter is 4
> Counter is 5
> You made it through!
```

```ruby
# Rescue only certain errors

3.tries on: FooError do
  method_that_raises_exception
end

> Counter is 1
> Counter is 2
> Counter is 3
> BarError: BarError

3.tries on: [FooError, BarError] do
  method_that_raises_exception
end

> Counter is 1
> Counter is 2
> Counter is 3
> Counter is 4
> StandardError: StandardError
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
