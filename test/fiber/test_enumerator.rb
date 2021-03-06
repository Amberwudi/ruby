# frozen_string_literal: true
require 'test/unit'
require 'socket'
require_relative 'scheduler'

class TestSchedulerEnumerator < Test::Unit::TestCase
  MESSAGE = "Hello World"

  def test_read_characters
    skip unless defined?(UNIXSocket)

    i, o = UNIXSocket.pair
    skip unless i.nonblock? && o.nonblock?

    message = String.new

    thread = Thread.new do
      scheduler = Scheduler.new
      Thread.current.scheduler = scheduler

      e = i.to_enum(:each_char)

      Fiber do
        o.write("Hello World")
        o.close
      end

      Fiber do
        begin
          while c = e.next
            message << c
          end
        rescue StopIteration
          # Ignore.
        end

        i.close
      end
    end

    thread.join

    assert_equal(MESSAGE, message)
  end
end
