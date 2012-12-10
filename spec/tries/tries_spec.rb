require 'spec_helper'

describe Tries do
  before do
    @error_counter = 0
  end

  context 'when retrying on all errors' do
    it 'retries at least the defined number of times' do
      expect do
        5.tries do
          raise_foo_foo_bar_bar_standard
        end
      end.to_not raise_error
    end

    it 'retries max the defined number of times' do
      expect do
        3.tries do
          raise_foo_foo_bar_bar_standard
        end
      end.to raise_error(BarError)
    end
  end

  context 'when retrying only on one error' do
    it 'retries at least the defined number of times' do
      expect do
        2.tries on: FooError do
          raise_foo_foo_bar_bar_standard
        end
      end.to raise_error(BarError)
    end

    it 'retries max the defined number of times' do
      expect do
        1.tries on: FooError do
          raise_foo_foo_bar_bar_standard
        end
      end.to raise_error(FooError)
    end
  end

  context 'when retrying on multiple errors' do
    it 'retries at least the defined number of times' do
      expect do
        5.tries on: [FooError, BarError] do
          raise_foo_foo_bar_bar_standard
        end
      end.to raise_error(StandardError)
    end

    it 'retries max the defined number of times' do
      expect do
        3.tries on: [FooError, BarError] do
          raise_foo_foo_bar_bar_standard
        end
      end.to raise_error(BarError)
    end
  end

  context 'when specifying a delay' do
    let(:delay) { 1.1 }

    it 'sleeps the specified delay' do
      Kernel.should_receive(:sleep).with(delay).exactly(2).times

      begin
        3.tries on: FooError, delay: delay do
          raise_foo_foo_bar_bar_standard
        end
      rescue StandardError
      end
    end
  end
end

FooError = Class.new(StandardError)
BarError = Class.new(StandardError)

def raise_foo_foo_bar_bar_standard
  @error_counter += 1

  case @error_counter
  when 1
    raise FooError
  when 2
    raise FooError
  when 3
    raise BarError
  when 4
    raise BarError
  when 5
    raise StandardError
  end
end
