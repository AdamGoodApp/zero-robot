require 'concurrent/scheduled_task'
require 'concurrent/executor/thread_pool_executor'
require 'concurrent/utility/processor_counter'

module ActiveJob
  module QueueAdapters
    class ScheduledQueue
      def initialize(**executor_options, &block)
        @config = Configuration.new(&block)
        @scheduler = Scheduler.new(@config, **executor_options)
      end

      def enqueue(job)
        @config.queues[job.queue_name.to_sym] << job
      end

      def enqueue_at(*)
        raise NotImplementedError, "This queue doesn't support explicitly delayed jobs (they all are delayed by design)"
      end

      def shutdown(wait: true)
        @scheduler.shutdown wait: wait
      end

      class Queue
        def initialize
          @job = nil
          @lock = Mutex.new
        end

        def execute
          job = nil
          @lock.synchronize do
            return if @job.nil?
            job = @job
            @job = nil
          end
          Base.execute job.serialize
        end

        def <<(job)
          @lock.synchronize do
            if @job.nil?
              job.arguments = [[job.arguments]]
              @job = job
            else
              @job.arguments[0] << job.arguments
            end
          end
        end
      end

      class Configuration
        attr_accessor :schedules, :queues

        def initialize(&block)
          @schedules = {}
          @queues = {}
          instance_eval(&block)
        end

        def schedule(queue, every: nil)
          if every.nil?
            raise ArgumentError, "You need to specify a 'every' argument for '#{queue}'"
          end
          @schedules[queue] = {every: every}
          @queues[queue] = Queue.new
        end
      end

      class Scheduler
        DEFAULT_EXECUTOR_OPTIONS = {
          min_threads:     0,
          max_threads:     Concurrent.processor_count,
          auto_terminate:  true,
          idletime:        60,
          max_queue:       0,
          fallback_policy: :caller_runs
        }.freeze

        def initialize(config, **options)
          @stop = false
          @async_executor = Concurrent::ThreadPoolExecutor.new(DEFAULT_EXECUTOR_OPTIONS.merge(options))
          setup_schedules(config)
        end

        def setup_schedules(config)
          config.schedules.each do | name, options |
            queue = config.queues[name]
            schedule_block = Proc.new do | &block |
              Concurrent::ScheduledTask.execute(options[:every], args: [], executor: @async_executor, &block)
            end

            execute_block = Proc.new do
              begin
                queue.execute
              rescue => e
                Rails.logger.debug("Exception while executing scheduled task: #{e}\n\t#{e.backtrace.join("\n\t")}")
              ensure
                schedule_block.call(&execute_block) unless @stop
              end
            end

            schedule_block.call(&execute_block)
          end
        end

        def shutdown(wait: true)
          @stop = true
          @async_executor.shutdown
          @async_executor.wait_for_termination if wait
        end
      end
    end
  end
end
