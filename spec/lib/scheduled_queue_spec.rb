describe ActiveJob::QueueAdapters::ScheduledQueue do
  describe '.initialize' do
    it 'sets attributes correctly' do
      block = Proc.new {}
      config = double('config') ; scheduler = double('scheduler')
      opts = {coucou: 'hey', hello: 'ho'}
      expect(described_class::Configuration).to receive(:new).once.with(no_args, &block).and_return(config)
      expect(described_class::Scheduler).to receive(:new).once.with(config, opts).and_return(scheduler)
      q = described_class.new(**opts, &block)
      expect(q.instance_variable_get(:@config)).to be(config)
      expect(q.instance_variable_get(:@scheduler)).to be(scheduler)
    end
  end

  describe '.enqueue' do
    it 'queues the job' do
      q = described_class.new do
        schedule :work, every: 16.hours
      end
      job = double('job', queue_name: 'work')
      expect(q.instance_variable_get(:@config).queues[:work]).to receive(:<<).with(job)
      q.enqueue job
    end
  end

  describe '.enqueue_at' do
    it 'raises an error' do
      q = described_class.new {}
      expect { q.enqueue_at 'send', whatever: 'you want' }.to raise_error(NotImplementedError, "This queue doesn't support explicitly delayed jobs (they all are delayed by design)")
    end
  end

  describe '.shutdown' do
    it 'stops the scheduler' do
      q = described_class.new {}
      expect(q.instance_variable_get(:@scheduler)).to receive(:shutdown).with(wait: true)
      q.shutdown
    end

    it 'stops the scheduler (does not wait)' do
      q = described_class.new {}
      expect(q.instance_variable_get(:@scheduler)).to receive(:shutdown).with(wait: false)
      q.shutdown wait: false
    end
  end

  describe '::Queue' do
    def new_queue
      described_class::Queue.new
    end

    describe '.initialize' do
      it 'sets attributes correctly' do
        q = new_queue
        expect(q.instance_variable_get(:@job)).to be(nil)
        expect(q.instance_variable_get(:@lock)).to be_a(Mutex)
      end
    end

    describe '.execute' do
      it 'executes a job' do
        args = {abc: 123}
        job = double('job', arguments: args)
        serialized = {hello: 123}

        q = new_queue
        expect(job).to receive(:arguments=).once.with([[args]])
        q << job
        expect(q.instance_variable_get(:@job)).not_to be(nil)
        expect(q.instance_variable_get(:@lock)).to receive(:synchronize).once.and_call_original
        expect(ActiveJob::Base).to receive(:execute).with(serialized)
        expect(job).to receive(:serialize).once.with(no_args).and_return(serialized)
        q.execute
        expect(q.instance_variable_get(:@job)).to be(nil)
      end

      it 'does nothing' do
        q = new_queue
        expect(q.instance_variable_get(:@job)).to be(nil)
        expect(q.instance_variable_get(:@lock)).to receive(:synchronize).once.and_call_original
        expect(ActiveJob::Base).not_to receive(:execute)
        q.execute
      end
    end

    describe '.<<' do
      it 'stores the first job' do
        args = {abc: 123}
        job = double('job', arguments: args)

        q = new_queue
        expect(q.instance_variable_get(:@job)).to be(nil)
        expect(q.instance_variable_get(:@lock)).to receive(:synchronize).once.and_call_original
        expect(job).to receive(:arguments=).once.with([[args]])
        q << job
        expect(q.instance_variable_get(:@job)).to eq(job)
      end

      it 'stores a job' do
        args = {abc: 123} ; args2 = {a123: '1abc'}
        job = double('job', arguments: args)
        job2 = double('job2', arguments: args2)
        fake_args = double('fake_args') ; fake_sub_args = double('fake_sub_args')

        q = new_queue
        expect(q.instance_variable_get(:@lock)).to receive(:synchronize).twice.and_call_original

        expect(q.instance_variable_get(:@job)).to be(nil)
        expect(job).to receive(:arguments=).once.with([[args]])
        q << job
        expect(q.instance_variable_get(:@job)).to eq(job)

        expect(job).to receive(:arguments).once.with(no_args).and_return(fake_args)
        expect(fake_args).to receive(:[]).once.with(0).and_return(fake_sub_args)
        expect(fake_sub_args).to receive(:<<).once.with(args2)
        q << job2
        expect(q.instance_variable_get(:@job)).to eq(job)

      end
    end
  end

  describe '::Configuration' do
    def new_conf(&block)
      described_class::Configuration.new(&block)
    end

    describe '.initialize' do
      it 'sets attributes correctly' do
        block = Proc.new {}
        expect_any_instance_of(described_class::Configuration).to receive(:instance_eval).once.with(no_args, &block)
        c = new_conf(&block)
        expect(c.schedules).to eq({})
        expect(c.queues).to eq({})
      end

      it 'schedules using DSL' do
        expect_any_instance_of(described_class::Configuration).to receive(:schedule).once.with(:laundry, every: 8.days)
        c = new_conf do
          schedule :laundry, every: 8.days
        end
      end
    end

    describe '.schedule' do
      it 'schedules a job' do
        c = new_conf {}
        expect(c.schedules[:shower]).to be(nil)
        expect(c.queues[:shower]).to be(nil)
        c.schedule(:shower, every: 24.hours)
        expect(c.schedules[:shower]).to eq({every: 24.hours})
        expect(c.queues[:shower]).to be_a(described_class::Queue)
      end

      it 'fails if every is not specified' do
        c = new_conf {}
        expect(c.schedules[:work]).to be(nil)
        expect(c.queues[:work]).to be(nil)
        expect { c.schedule(:work) }.to raise_error(ArgumentError, "You need to specify a 'every' argument for 'work'")
        expect(c.schedules[:work]).to be(nil)
        expect(c.queues[:work]).to be(nil)
      end
    end
  end

  describe '::Scheduler' do
    def new_sched(config, options)
      described_class::Scheduler.new(config, options)
    end

    describe '.initialize' do
      it 'sets attributes correctly' do
        executor = double('executor')
        expect_any_instance_of(described_class::Scheduler).to receive(:setup_schedules).once.with(config)
        expect(Concurrent::ThreadPoolExecutor).to receive(:new).once.with(
          min_threads: 4, max_threads: Concurrent.processor_count, auto_terminate: true, idletime: 60, max_queue: 0, fallback_policy: :caller_runs
        ).and_return(executor)
        s = new_sched(config, min_threads: 4)
        expect(s.instance_variable_get(:@stop)).to be(false)
        expect(s.instance_variable_get(:@async_executor)).to be(executor)
      end
    end

    describe '.setup_schedules' do
      it 'runs the queues' do
        s = new_sched(described_class::Configuration.new {}, {})
        queue = double('queue')
        expect(queue).to receive(:execute).once.with(no_args)
        config = double('config', schedules: {sneeze: {every: 1.second}}, queues: {sneeze: queue})

        count = 0
        expect(Concurrent::ScheduledTask).to receive(:execute).once.with(1.second, args: [], executor: s.instance_variable_get(:@async_executor)) do |&block|
          if count < 5
            s.instance_variable_set(:@stop, true) if count == 0
            block.call
          end
          count += 1
        end
        s.setup_schedules(config)
        expect(count).to be(1)
      end

      it 'runs the queues (two loops)' do
        s = new_sched(described_class::Configuration.new {}, {})
        queue = double('queue')
        expect(queue).to receive(:execute).twice.with(no_args)
        config = double('config', schedules: {sneeze: {every: 1.second}}, queues: {sneeze: queue})

        count = 0
        expect(Concurrent::ScheduledTask).to receive(:execute).twice.with(1.second, args: [], executor: s.instance_variable_get(:@async_executor)) do |&block|
          if count < 5
            s.instance_variable_set(:@stop, true) if count == 1
            count += 1
            block.call
          end
        end
        s.setup_schedules(config)
        expect(count).to be(2)
      end

      it 'recovers from job\'s exceptions' do
        s = new_sched(described_class::Configuration.new {}, {})
        queue = double('queue')
        expect(queue).to receive(:execute).twice.with(no_args) do
          raise ArgumentError, "FAILED!"
        end
        config = double('config', schedules: {sneeze: {every: 1.second}}, queues: {sneeze: queue})

        count = 0
        expect(Rails.logger).to receive(:debug).twice.with(/Exception while executing scheduled task:/)
        expect(Concurrent::ScheduledTask).to receive(:execute).twice.with(1.second, args: [], executor: s.instance_variable_get(:@async_executor)) do |&block|
          if count < 5
            s.instance_variable_set(:@stop, true) if count == 1
            count += 1
            block.call
          end
        end
        s.setup_schedules(config)
        expect(count).to be(2)
      end
    end

    describe '.shutdown' do
      it 'waits for termination' do
        s = new_sched(described_class::Configuration.new {}, {})
        expect(s.instance_variable_get(:@stop)).to be(false)
        expect(s.instance_variable_get(:@async_executor)).to receive(:shutdown).once.with(no_args)
        expect(s.instance_variable_get(:@async_executor)).to receive(:wait_for_termination).once.with(no_args)
        s.shutdown
        expect(s.instance_variable_get(:@stop)).to be(true)
      end

      it 'stops immediately' do
        s = new_sched(described_class::Configuration.new {}, {})
        expect(s.instance_variable_get(:@stop)).to be(false)
        expect(s.instance_variable_get(:@async_executor)).to receive(:shutdown).once.with(no_args)
        expect(s.instance_variable_get(:@async_executor)).not_to receive(:wait_for_termination)
        s.shutdown(wait: false)
        expect(s.instance_variable_get(:@stop)).to be(true)
      end
    end
  end
end
