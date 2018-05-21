require 'protocol/eva_pb'

describe ZeroMQ do

  describe '.run' do
    it 'initializes everything' do
      expect(Rails.env).to receive(:test?).once.with(no_args).and_return(false)
      expect(subject.class).to receive(:launch_thread).once.with(no_args)
      subject.class.run
      expect(subject.class.class_variable_get(:@@stop)).to be(false)
      expect(subject.class.class_variable_get(:@@messages)).to eq([])
      expect(subject.class.class_variable_get(:@@lock)).to be_a(Mutex)
      expect(subject.class.class_variable_get(:@@notifier)).to be_a(ConditionVariable)
    end
  end

  describe '.launch_thread' do
    it 'starts a thread managing I/O' do
      expect(subject.class.class_variable_defined?(:@@zmq_thread)).to be(false)

      expect(ZL).to receive(:stop).once.with(no_args)

      ctx = double('ctx') ; socket = double('socket')
      expect(ZMQ::Context).to receive(:new).once.with(no_args).and_return(ctx)
      expect(ctx).to receive(:socket).once.with(ZMQ::DEALER).and_return(socket)
      expect(ZL).to receive(:run) do |&block|
        expect(ZL).to receive(:connect).with(socket, "tcp://127.0.0.1:10456", ZeroMQ::SocketHandler, subject.class.class_variable_get(:@@lock), subject.class.class_variable_get(:@@messages))
        expect(ZL).to receive(:add_periodic_timer).with(0.5) do |&block|
          block.call
        end
        block.call
      end

      expect(subject.class).to receive(:at_exit) do |&block|
        expect(subject.class.class_variable_get(:@@stop)).to be(false)
        expect(subject.class.class_variable_get(:@@zmq_thread)).to receive(:join).once.with(no_args).and_call_original
        block.call
        expect(subject.class.class_variable_get(:@@stop)).to be(true)
      end

      subject.class.launch_thread
      expect(subject.class.class_variable_get(:@@zmq_thread)).to be_a(Thread)
    end
  end

  describe '.send' do
    it 'sync and stores a message in the send queue' do
      pre_msg = double('pre_msg') ; msg = double('msg')
      expect(Eva::Message).to receive(:encode).once.with(pre_msg).and_return(msg)

      expect(subject.class.class_variable_get(:@@messages)).to eq([])

      expect(subject.class.class_variable_get(:@@lock)).to receive(:synchronize).once.with(no_args).and_yield
      expect(subject.class.class_variable_get(:@@notifier)).to receive(:signal).once.with(no_args)
      subject.class.send(pre_msg)

      expect(subject.class.class_variable_get(:@@messages)).to eq([msg])
    end
  end

  describe '::SocketHandler' do
    describe '.initialize' do
      it 'sets attributes correctly' do
        item = ZMQ::Pollitem.new($stdout) ; lock = double('lock') ; messages = double('messages')
        handler = ZeroMQ::SocketHandler.new(item, [lock, messages])
        expect(handler).to be_a(ZMQ::Handler)
        expect(handler.instance_variable_get(:@lock)).to be(lock)
        expect(handler.instance_variable_get(:@messages)).to be(messages)
      end
    end

    describe '.on_readable' do
      it 'calls the deserialize jog' do
        item = ZMQ::Pollitem.new($stdout) ; lock = double('lock') ; messages = double('messages') ; msg = double('msg')
        handler = ZeroMQ::SocketHandler.new(item, [lock, messages])

        expect(handler).to receive(:recv).once.with(no_args).and_return(msg)
        expect(DeserializeJob).to receive(:perform_later).once.with(msg)

        handler.on_readable
      end
    end

    describe '.on_writable' do
      it 'pops and sends a message from the queue' do
        item = ZMQ::Pollitem.new($stdout) ; lock = double('lock') ; messages = double('messages') ; msg = double('msg')
        handler = ZeroMQ::SocketHandler.new(item, [lock, messages])

        expect(lock).to receive(:synchronize).once.with(no_args).and_yield
        expect(messages).to receive(:length).once.with(no_args).and_return(1)
        expect(messages).to receive(:shift).once.with(no_args).and_return(msg)
        expect(handler).to receive(:send).once.with(msg)

        handler.on_writable
      end

      it 'does nothing (no message)' do
        item = ZMQ::Pollitem.new($stdout) ; lock = double('lock') ; messages = double('messages')
        handler = ZeroMQ::SocketHandler.new(item, [lock, messages])

        expect(lock).to receive(:synchronize).once.with(no_args).and_yield
        expect(messages).to receive(:length).once.with(no_args).and_return(0)
        expect(messages).not_to receive(:shift)
        expect(handler).not_to receive(:send)

        handler.on_writable
      end
    end
  end
end
