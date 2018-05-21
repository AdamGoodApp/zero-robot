class ZeroMQ
  class SocketHandler < ZMQ::Handler
    def initialize(item, args)
      super
      @lock = args[0]
      @messages = args[1]
    end

    def on_readable
      message = recv
      DeserializeJob.perform_later(message)
    end

    def on_writable
      @lock.synchronize do
        return if @messages.length == 0
        send @messages.shift
      end
    end
  end

  def self.run
    @@messages = []
    @@lock = Mutex.new
    @@notifier = ConditionVariable.new

    @@stop = false

    ZeroMQ.launch_thread if not Rails.env.test?
  end

  def self.launch_thread
    @@zmq_thread = Thread.new do
      ctx = ZMQ::Context.new
      socket = ctx.socket(ZMQ::DEALER)

      ZL.run do
        ZL.connect(socket, "tcp://127.0.0.1:10456", SocketHandler, @@lock, @@messages)
        ZL.add_periodic_timer(0.5) do
          ZL.stop if @@stop
        end
      end
    end

    at_exit do
      @@stop = true
      @@zmq_thread.join
    end
  end

  def self.send(message)
    @@lock.synchronize do
      @@messages << Eva::Message.encode(message)
      @@notifier.signal
    end
  end
end
