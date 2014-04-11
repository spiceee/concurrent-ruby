require 'spec_helper'

module Concurrent

  describe '#timer' do

    it 'raises an exception when no block given' do
      expect {
        Concurrent::timer(0.1)
      }.to raise_error(ArgumentError)
    end

    it 'raises an exception if the interval is less than 0 seconds' do
      expect {
        Concurrent::timer(-1){ :foo }
      }.to raise_error(ArgumentError)
    end

    it 'executes the block after the given number of seconds' do
      start = Time.now
      expected = Concurrent::AtomicFixnum.new(0)
      Concurrent::timer(0.5){ expected.increment }
      expected.value.should eq 0
      sleep(0.2)
      expected.value.should eq 0
      sleep(0.5)
      expected.value.should eq 1
    end

    it 'suppresses exceptions thrown by the block' do
      expect {
        Concurrent::timer(0.5){ raise Exception }
      }.to_not raise_error
    end

    it 'runs the task on the global timer pool' do
      Concurrent.configuration.global_timer_pool.should_receive(:post).with(no_args)
      Concurrent::timer(0.1){ :foo }
    end
  end
end
