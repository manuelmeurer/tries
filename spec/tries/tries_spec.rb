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
    let(:delay) { 0.1 }

    context 'static delay' do
      it 'sleeps the specified delay' do
        expect(Kernel).to receive(:sleep).with(0.1).exactly(2).times

        begin
          3.tries on: FooError, delay: delay do
            raise_foo_foo_bar_bar_standard
          end
        rescue StandardError
        end
      end
    end

    context 'incremental delay' do
      it 'sleeps incrementally' do
        expect(Kernel).to receive(:sleep).with(0.1).ordered
        expect(Kernel).to receive(:sleep).with(0.2).ordered
        expect(Kernel).to receive(:sleep).with(0.3).ordered

        begin
          3.tries on: [FooError, BarError], delay: delay, incremental: true do
            raise_foo_foo_bar_bar_standard
          end
        rescue StandardError
        end
      end
    end
  end

  context 'on_error' do
    context 'when a global callback is set' do
      it 'calls the global callback with the correct parameters' do
        global_on_error = Proc.new {}
        Tries.configure do |config|
          config.on_error = global_on_error
        end
        expect(global_on_error).to receive(:call).with(an_instance_of(FooError), 1, 0.1).ordered
        expect(global_on_error).to receive(:call).with(an_instance_of(FooError), 2, 0.2).ordered
        expect(global_on_error).to receive(:call).with(an_instance_of(BarError), 3, 0.3).ordered
        begin
          3.tries on: [FooError, BarError], delay: 0.1, incremental: true do
            raise_foo_foo_bar_bar_standard
          end
        rescue StandardError
        end
      end
    end

    context 'when a local callback is set' do
      it 'calls the local callback with the correct parameters' do
        local_on_error = Proc.new {}
        expect(local_on_error).to receive(:call).with(an_instance_of(FooError), 1, 0.1).ordered
        expect(local_on_error).to receive(:call).with(an_instance_of(FooError), 2, 0.2).ordered
        expect(local_on_error).to receive(:call).with(an_instance_of(BarError), 3, 0.3).ordered
        begin
          3.tries on: [FooError, BarError], delay: 0.1, incremental: true, on_error: local_on_error do
            raise_foo_foo_bar_bar_standard
          end
        rescue StandardError
        end
      end
    end

    context 'when both a global and a local callback are set' do
      it 'calls both callbacks with the correct parameters in the correct order' do
        local_on_error, global_on_error = Proc.new {}, Proc.new {}
        expect(global_on_error).to receive(:call).with(an_instance_of(FooError), 1, 0.1).ordered
        expect(local_on_error).to receive(:call).with(an_instance_of(FooError), 1, 0.1).ordered
        expect(global_on_error).to receive(:call).with(an_instance_of(FooError), 2, 0.2).ordered
        expect(local_on_error).to receive(:call).with(an_instance_of(FooError), 2, 0.2).ordered
        expect(global_on_error).to receive(:call).with(an_instance_of(BarError), 3, 0.3).ordered
        expect(local_on_error).to receive(:call).with(an_instance_of(BarError), 3, 0.3).ordered
        Tries.configure do |config|
          config.on_error = global_on_error
        end
        begin
          3.tries on: [FooError, BarError], delay: 0.1, incremental: true, on_error: local_on_error do
            raise_foo_foo_bar_bar_standard
          end
        rescue StandardError
        end
      end
    end
  end
end

FooError = Class.new(StandardError)
BarError = Class.new(StandardError)

def raise_foo_foo_bar_bar_standard
  @error_counter += 1

  case @error_counter
  when 1 then raise FooError
  when 2 then raise FooError
  when 3 then raise BarError
  when 4 then raise BarError
  when 5 then raise StandardError
  end
end
